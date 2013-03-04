From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [RFC PATCH 0/5] net: low latency Ethernet device polling
Date: Mon, 04 Mar 2013 10:19:58 +0200
Message-ID: <5134592E.6050508@linux.intel.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com> <51344F54.8060809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51344F54.8060809@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 04/03/2013 09:37, Cong Wang wrote:
> On 02/28/2013 01:55 AM, Eliezer Tamir wrote:
>>
>> Open issues:
>> 1. Find a way to avoid the need to change the sk and skb structs.
>> One big disadvantage of how we do this right now is that when a device is
>> removed, it's hard to prevent it from getting polled by a socket
>> which holds a stale reference.
>>
>> 2. How do we decide which sockets are eligible to do busy polling?
>> Do we add a socket option to control this?
>> How do we provide sane defaults while allowing flexibility and
>> performance?
>>
>> 3. Andi Kleen and HPA pointed out that using get_cycles() is not
>> portable.
>>
>> 4. How and where do we call ndo_ll_poll from the socket code?
>> One good place seems to be wherever the kernel puts the process to sleep,
>> waiting for more data, but this makes doing something intelligent about
>> poll (the system call) hard. From the perspective of how ndo_ll_poll
>> itself is implemented this does not seem to matter.
>>
>> 5. I would like to hear suggestions on naming conventions and where
>> to put the code that for now I have put in include/net/ll_poll.h
>>
>
>
> A dumb question: is bypassing tcpdump/netfilters/qdisc etc. what we
> always want? Isn't this a security issue?

We are not bypassing any of the regular stack checks/hooks, we call the 
normal netif_rx_skb().

Thanks,
Eliezer
