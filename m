From: Christopher Chan <cchan@outblaze.com>
Subject: Re: [PATCH 2.6] e100: use NAPI mode all the time
Date: Wed, 16 Jun 2004 02:04:37 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40CF3A35.3070906@outblaze.com>
References: <Pine.LNX.4.58.0406041727160.2662@sfeldma-ich5.jf.intel.com> <40C58CA2.4090107@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scott.feldman@intel.com>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christopher Chan <cchan@outblaze.com>
In-Reply-To: <40C58CA2.4090107@outblaze.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christopher Chan wrote:
> Scott Feldman wrote:
> 
>> I see no reason to keep the non-NAPI option for e100.  This patch removes
>> the CONFIG_E100_NAPI option and puts the driver in NAPI mode all the 
>> time.
>> Matches the way tg3 works.
>>
>> Unless someone has a really good reason to keep the non-NAPI mode, this
>> should go in for 2.6.7.
> 
> 
> I for one need to test 2.6.6 e100 with NAPI on. Under 2.6.3/4 I had 
> problems with NAPI mode turned on. Turning NAPI off and then also doing
> 
> net.ipv4.tcp_max_syn_backlog = 2048
> net.ipv4.route.gc_thresh = 65536
> net.ipv4.route.max_size = 1048576
> 
> was the only way to keep the machines I run available via the network.
> 
> I would get dst cache overflows and sometimes the kernel will log 
> garbled messages and when that happens the box requires a reboot.
> 

KERNEL: assertion (tp->copied_seq == tp->rcv_nxt || (flags & (MSG_PEEK | 
MSG_TRUNC))) failed at net/ipv4/tcp.c (1632)
KERNEL: assertion (flags & MSG_PEEK) failed at net/ipv4/tcp.c (1568)
KERNEL: assertion (tp->copied_seq == tp->rcv_nxt || (flags & (MSG_PEEK | 
MSG_TRUNC))) failed at net/ipv4/tcp.c (1632)
KERNEL: assertion (flags & MSG_PEEK) failed at net/ipv4/tcp.c (1568)
printk: 4253 messages suppressed.
dst cache overflow
KERNEL: assertion (tp->copied_seq == tp->rcv_nxt || (flags & (MSG_PEEK | 
MSG_TRUNC))) failed at net/ipv4/tcp.c (1632)
KERNEL: assertion (flags & MSG_PEEK) failed at net/ipv4/tcp.c (1568)
KERNEL: assertion (tp->copied_seq == tp->rcv_nxt || (flags & (MSG_PEEK | 
MSG_TRUNC))) failed at net/ipv4/tcp.c (1632)
KERNEL: assertion (flags & MSG_PEEK) failed at net/ipv4/tcp.c (1568)
KERNEL: assertion (tp->copied_seq == tp->rcv_nxt || (flags & (MSG_PEEK | 
MSG_TRUNC))) failed at net/ipv4/tcp.c (1632)
KERNEL: assertion (flags & MSG_PEEK) failed at net/ipv4/tcp.c (1568)
KERNEL: assertion (tp->copied_seq == tp->rcv_nxt || (flags & (MSG_PEEK | 
MSG_TRUNC))) failed at net/ipv4/tcp.c (1632)

I get loads of this now for the only box that I have NAPI enabled on the 
e100 driver.

This is on a 2.6.6 kernel.
