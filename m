From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/flow: remove sleeping and deferral mechanism from
 flow_cache_flush
Date: Wed, 21 Dec 2011 16:48:36 -0500 (EST)
Message-ID: <20111221.164836.1819643617176570312.davem@davemloft.net>
References: <20110927.153132.900366550174236643.davem@davemloft.net>
	<20111220082332.GN6348@secunet.com>
	<4EF04A44.6060400@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steffen.klassert@secunet.com, madalin.bucur@freescale.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418Ab1LUVs4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 16:48:56 -0500
In-Reply-To: <4EF04A44.6060400@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Tue, 20 Dec 2011 10:41:40 +0200

> On 12/20/2011 10:23 AM, Steffen Klassert wrote:
>> On Tue, Sep 27, 2011 at 03:31:32PM -0400, David Miller wrote:
>>> From: David Miller <davem@davemloft.net>
>>> Date: Tue, 27 Sep 2011 15:28:36 -0400 (EDT)
>>>
>>>> afinfo->garbage_collect is the only other place __xfrm_garbage_col=
lect
>>>> is referenced, and that is completely unused and should thus be de=
leted
>>>> (I'll take care of that in net-next).
>>>
>>> Nevermind I see how these are referenced directly via xfrm4_policy.=
c
>>> and xfrm6_policy.c, sigh...
>>=20
>> Is there any progress in fixing this issue? I've seen this occasiona=
lly
>> on some of our production systems, so I fixed it for us in the meant=
ime
>> with the patch below. I could submit this for inclusion if noone els=
e
>> wants to fix it in a different manner.
>>=20
>> ------
>> net: Add a flow_cache_flush_deferred function
>>=20
>> flow_cach_flush() might sleep but can be called from
>> atomic context via the xfrm garbage collector. So add
>> a flow_cache_flush_deferred() function and use this if
>> the xfrm garbage colector is invoked from within the
>> packet path.
>>=20
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>=20
> Acked-by: Timo Ter=E4s <timo.teras@iki.fi>
>=20
> I was first thinking if it made sense to run the local CPUs task
> immediately on gc. But since all it does is queue the removed nodes t=
o
> the second gc that actually frees the dst's, it doesn't really make a
> difference.
>=20
> So this is probably as good as it gets.

Applied, thanks everyone.
