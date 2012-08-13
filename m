From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH] XFRM: remove redundant parameter "int dir" in struct
 xfrm_mgr.acquire
Date: Mon, 13 Aug 2012 15:23:09 +0800
Message-ID: <5028AB5D.9040200@windriver.com>
References: <1344839157-25797-1-git-send-email-fan.du@windriver.com> <20120813070841.GP1869@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:43120 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216Ab2HMHRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2012 03:17:53 -0400
In-Reply-To: <20120813070841.GP1869@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012=E5=B9=B408=E6=9C=8813=E6=97=A5 15:08, Steffen Klassert wrote:
> On Mon, Aug 13, 2012 at 02:25:57PM +0800, Fan Du wrote:
>>
>>   static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmp=
l *xt,
>> -			     struct xfrm_policy *xp, int dir)
>> +			     struct xfrm_policy *xp)
>>   {
>>   	struct net *net =3D xs_net(x);
>>   	struct sk_buff *skb;
>> @@ -2614,7 +2614,7 @@ static int xfrm_send_acquire(struct xfrm_state=
 *x, struct xfrm_tmpl *xt,
>>   	if (skb =3D=3D NULL)
>>   		return -ENOMEM;
>>
>> -	if (build_acquire(skb, x, xt, xp, dir)<  0)
>> +	if (build_acquire(skb, x, xt, xp, XFRM_POLICY_OUT)<  0)
>>   		BUG();
>
> xfrm_send_acquire() is the only caller of build_acquire().
> So if you remove the dir parameter from xfrm_send_acquire(),
> you can remove it from build_acquire() too.
>
Yep, looks like we can only remove "dir" at build_acquire, not into
copy_to_user_policy anymore :)

I will adopt your approach in v2 if Dave say *YES* about this patch.
thanks anyway.

--=20

Love each day!
--fan
