From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] Handle shared SKBs in VLAN receive code
Date: Sat, 11 Oct 2003 12:03:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F885418.3090407@candelatech.com>
References: <3F87430D.2040000@tpack.net> <3F87464B.1020908@candelatech.com> <3F874A30.6010700@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <3F874A30.6010700@tpack.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tommy Christensen wrote:
> Ben Greear wrote:
> 
>>> -        if (skb_shared(skb) || skb_cloned(skb)) {
>>> -            struct sk_buff *nskb = skb_copy(skb, GFP_ATOMIC);
>>> -            kfree(skb);
>>> -            skb = nskb;
>>> -        }
>>> +        skb = skb_unshare(skb, GFP_ATOMIC);
>>
>>
>>
>> On 2.4.22, at least, skb_unshare only checks skb_cloned(), so do we
>> also need to check skb_shared()?  Or was that check in the old patch 
>> above
>> not needed?
> 
> 
> skb_shared() is now taken care of by skb_share_check(), called earlier 
> in the
> receive routine.

Maybe we should have a method called:  skb_get_me_an_skb_that_I_can_modify(skb);

Then the subtle differences between sharing, cloning, etc can be handled
by the skb code internally...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
