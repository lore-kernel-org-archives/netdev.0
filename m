From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] Handle shared SKBs in VLAN receive code
Date: Sat, 11 Oct 2003 02:09:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F874A30.6010700@tpack.net>
References: <3F87430D.2040000@tpack.net> <3F87464B.1020908@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:

>> -        if (skb_shared(skb) || skb_cloned(skb)) {
>> -            struct sk_buff *nskb = skb_copy(skb, GFP_ATOMIC);
>> -            kfree(skb);
>> -            skb = nskb;
>> -        }
>> +        skb = skb_unshare(skb, GFP_ATOMIC);
> 
> 
> On 2.4.22, at least, skb_unshare only checks skb_cloned(), so do we
> also need to check skb_shared()?  Or was that check in the old patch above
> not needed?

skb_shared() is now taken care of by skb_share_check(), called earlier in the
receive routine.

Admittedly, the naming is not very helpful. skb_share_check() handles shared
sk_buff's, while skb_unshare() handles cloned sk_buff's. Well ...


-Tommy
