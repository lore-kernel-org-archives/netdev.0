From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH, v2] net: release dst entry in dev_hard_start_xmit()
Date: Tue, 19 May 2009 23:21:12 +0200
Message-ID: <4A1322C8.7060508@cosmosbay.com>
References: <4A092F59.7020900@cosmosbay.com> <4A093178.9020105@cosmosbay.com> <4A09CD6B.5070604@cosmosbay.com> <20090518.221956.153457626.davem@davemloft.net> <4A130C0E.6000507@cosmosbay.com> <20090519210937.GA4850@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34185 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbZESVVU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 17:21:20 -0400
In-Reply-To: <20090519210937.GA4850@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Tue, May 19, 2009 at 09:44:14PM +0200, Eric Dumazet wrote:
>> David Miller a =E9crit :
>>> From: Eric Dumazet <dada1@cosmosbay.com>
>>> Date: Tue, 12 May 2009 21:26:35 +0200
>>>
>>>> [PATCH] net: release dst entry in dev_hard_start_xmit()
>>>  ...
>>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>> Applied, thanks Eric.
>>>
>>> Eric, please followup and double-check the pppoe paths
>>> that Jarek mentioned.  I never saw that fully resolved.
>>>
>> [PATCH] ppp: unset IFF_XMIT_DST_RELEASE in ppp_setup()
>>
>> Jarek pointed pppoe can call back dev_queue_xmit(), and might need
>> skb->dst, so its safer to unset IFF_XMIT_DST_RELEASE on ppp devices.
>=20
> Hmm... Of course, this patch looks OK to me, but actually my main
> concern was more general. We avoid adding such flags for each "real"
> dev, but if so IMHO it would be safer to generally add them to all
> "virtual" devs - needed or not. You prefer to do this only where
> necessary, but it's not always clear if it's omitted on purpose or
> by chance. So, now I'm wondering about xen-netfront - needlessly I
> hope ;-)
>=20

This is the deal in fact, tracking all valid uses, and I'll check this.

Another path would have to set the flag only for fast devices (Gb and 1=
0Gb)



