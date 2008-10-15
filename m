From: Abdul Basit <abasit@bnet6.net>
Subject: Re: qdisc tbf dropping many packets
Date: Wed, 15 Oct 2008 19:14:14 -0400
Message-ID: <48F67946.9000308@bnet6.net>
References: <6dd1343e0810090644r5b586fa4gd63ee6659b3a07c4@mail.gmail.com>	<48F54940.6050105@bnet6.net> <20081014.214849.20773661.davem@davemloft.net> <48F5BC30.5000205@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <48F5BC30.5000205@trash.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Patrick, disabling the ETH TSO helped, TBF is working okay now.

Thanks again,
~Basit

Patrick McHardy wrote:
> David Miller wrote:
>> From: Abdul Basit <abasit@bnet6.net>
>> Date: Tue, 14 Oct 2008 21:37:04 -0400
>>
>> [ netdev CC:'d, you'll reach more knowledgable people there ]
>>
>>> I am running linux kernel 2.6.23.1 on PowerPC and trying to set 
>>> qdisc tbf  to limit the rate:-
>>> *
>>> *==> tc qdisc add dev eth0 root tbf rate 2048kbit buffer 10kb 
>>> latency 50ms
>>>
>>> The problem is no matter what rate i specify, if I download a file 
>>> it always get down to ~16-18Kbps download speed,
>>> after investigating a bit more, i found by tc -s qdisc show that 
>>> many dropped packets show up in statistic s,
>>> looking further in kernel code, I found that in 
>>> linux/net/sched/sch_tbf.c:126
>>>
>>> static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
>>> {
>>>        struct tbf_sched_data *q = qdisc_priv(sch);
>>>        int ret;
>>>  if (skb->len > q->max_size) {
>>>                 printk (KERN_INFO "tbf_enqueue, drop skb->len = %d, 
>>> q->max_size = %d\n", skb->len, q->max_size);
>>>                 sch->qstats.drops++;
>>>
>>>         ....
>>> }
>>>
>>> whenever it try to enqueue the packet, the skb->len ( range from 
>>> 2980 - 2977 ) is usually greator than q->max_size ( 2907 )
>>> hence it drops the packet.
>>>
>>> On a different machine with same source code, skb->len never become 
>>> > 1500 and there the tbf works fine.
>>>
>>> Could someone please provide more insight or help where should i 
>>> look more?
>
> This appears to caused by TSO. Try disabling TSO using ethtool or
> configure TBF to handle larger packet sizes.


