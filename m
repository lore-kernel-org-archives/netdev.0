From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v5 net-next 3/5] tcp: add TCP support for low latency
 receive poll.
Date: Tue, 28 May 2013 15:15:24 +0300
Message-ID: <51A49FDC.2020608@linux.intel.com>
References: <20130527074351.29882.51106.stgit@ladj378.jer.intel.com>  <20130527074421.29882.73968.stgit@ladj378.jer.intel.com> <1369701413.3301.506.camel@edumazet-glaptop> <51A46A21.9060305@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51A46A21.9060305@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28/05/2013 11:26, Eliezer Tamir wrote:
> On 28/05/2013 03:36, Eric Dumazet wrote:
>> On Mon, 2013-05-27 at 10:44 +0300, Eliezer Tamir wrote:
>>>   #include <net/netdma.h>
>>>   #include <net/secure_seq.h>
>>>   #include <net/tcp_memcontrol.h>
>>> +#include <net/ll_poll.h>
>>>
>>>   #include <linux/inet.h>
>>>   #include <linux/ipv6.h>
>>> @@ -2011,6 +2012,7 @@ process:
>>>       if (sk_filter(sk, skb))
>>>           goto discard_and_relse;
>>>
>>> +    sk_mark_ll(sk, skb);
>>>       skb->dev = NULL;
>>>
>>>       bh_lock_sock_nested(sk);
>>
>> How IPv6 is handled ?

It turns out that adding TCPv6/UDPv6 is very simple.
I will add them, with a warning that I only did very limited testing.

-Eliezer
