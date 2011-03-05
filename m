From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 8/8 v2] net: get rid of orig_dev parameter
 of packet handlers
Date: Sat, 05 Mar 2011 23:18:02 +0100
Message-ID: <4D72B69A.3020103@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-9-git-send-email-jpirko@redhat.com> <20110305153247.GH8573@psychotron.redhat.com> <4D726B38.4040403@gmail.com> <20110305220752.GJ8573@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59457 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055Ab1CEWSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 17:18:06 -0500
Received: by wyg36 with SMTP id 36so3199324wyg.19
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 14:18:04 -0800 (PST)
In-Reply-To: <20110305220752.GJ8573@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/03/2011 23:07, Jiri Pirko a =E9crit :
> Sat, Mar 05, 2011 at 05:56:24PM CET, nicolas.2p.debian@gmail.com wrot=
e:
>> Le 05/03/2011 16:32, Jiri Pirko a =E9crit :
>>> Since orig_dev was used in af_packet (where it was replaced) and by
>>> bonding ptype handlers (which are no longer with us) only, orig_dev
>>> parameter is no longer needed ->   toss it out
>>>
>>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>> Reviewed-by: Nicolas de Peslo=FCan<nicolas.2p.debian@free.fr>
>>>
>> [snip]
>>
>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index 58daddb..c71bd18 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>> [snip]
>>> @@ -3216,13 +3214,13 @@ ncls:
>>>   		    (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=3D skb->de=
v ||
>>>   		     ptype->dev =3D=3D orig_dev)) {
>>>   			if (pt_prev)
>>> -				ret =3D deliver_skb(skb, pt_prev, orig_dev);
>>> +				ret =3D deliver_skb(skb, pt_prev);
>>>   			pt_prev =3D ptype;
>>>   		}
>>>   	}
>>>
>>>   	if (pt_prev) {
>>> -		ret =3D pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
>>> +		ret =3D pt_prev->func(skb, skb->dev, pt_prev);
>>>   	} else {
>>>   		atomic_long_inc(&skb->dev->rx_dropped);
>>>   		kfree_skb(skb);
>>
>> This part does not properly apply on top of current net-next-2.6.
>>
>> Line 3216 is currently
>>
>>                     (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=
=3D skb->dev)) {
>>
>> 	Nicolas.
>
>
> depends on "net: allow handlers to be processed for orig_dev" which i=
s a
> regression fixer
>

You are right. I reviewed this patch. :-)
