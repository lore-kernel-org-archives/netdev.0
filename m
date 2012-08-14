From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] XFRM: remove redundant parameter "int dir" in struct
 xfrm_mgr.acquire
Date: Tue, 14 Aug 2012 14:56:59 -0700 (PDT)
Message-ID: <20120814.145659.2264883418781808445.davem@davemloft.net>
References: <1344839157-25797-1-git-send-email-fan.du@windriver.com>
	<20120813070841.GP1869@secunet.com>
	<5028AB5D.9040200@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab2HNV5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 17:57:00 -0400
In-Reply-To: <5028AB5D.9040200@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Mon, 13 Aug 2012 15:23:09 +0800

> 
> 
> On 2012年08月13日 15:08, Steffen Klassert wrote:
>> On Mon, Aug 13, 2012 at 02:25:57PM +0800, Fan Du wrote:
>>>
>>>   static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl
>>>   *xt,
>>> -			     struct xfrm_policy *xp, int dir)
>>> +			     struct xfrm_policy *xp)
>>>   {
>>>   	struct net *net = xs_net(x);
>>>   	struct sk_buff *skb;
>>> @@ -2614,7 +2614,7 @@ static int xfrm_send_acquire(struct xfrm_state
>>> *x, struct xfrm_tmpl *xt,
>>>   	if (skb == NULL)
>>>   		return -ENOMEM;
>>>
>>> -	if (build_acquire(skb, x, xt, xp, dir)<  0)
>>> +	if (build_acquire(skb, x, xt, xp, XFRM_POLICY_OUT)<  0)
>>>   		BUG();
>>
>> xfrm_send_acquire() is the only caller of build_acquire().
>> So if you remove the dir parameter from xfrm_send_acquire(),
>> you can remove it from build_acquire() too.
>>
> Yep, looks like we can only remove "dir" at build_acquire, not into
> copy_to_user_policy anymore :)
> 
> I will adopt your approach in v2 if Dave say *YES* about this patch.
> thanks anyway.

Looks find to me.
