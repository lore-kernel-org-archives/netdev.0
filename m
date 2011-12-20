From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] net/flow: remove sleeping and deferral mechanism from
 flow_cache_flush
Date: Tue, 20 Dec 2011 10:41:40 +0200
Message-ID: <4EF04A44.6060400@iki.fi>
References: <1317056956-23644-1-git-send-email-madalin.bucur@freescale.com> <20110927.152836.1747700807304689813.davem@davemloft.net> <20110927.153132.900366550174236643.davem@davemloft.net> <20111220082332.GN6348@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, madalin.bucur@freescale.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:42954 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751234Ab1LTIlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 03:41:44 -0500
Received: by lahd3 with SMTP id d3so92992lah.19
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2011 00:41:43 -0800 (PST)
In-Reply-To: <20111220082332.GN6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2011 10:23 AM, Steffen Klassert wrote:
> On Tue, Sep 27, 2011 at 03:31:32PM -0400, David Miller wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Tue, 27 Sep 2011 15:28:36 -0400 (EDT)
>>
>>> afinfo->garbage_collect is the only other place __xfrm_garbage_coll=
ect
>>> is referenced, and that is completely unused and should thus be del=
eted
>>> (I'll take care of that in net-next).
>>
>> Nevermind I see how these are referenced directly via xfrm4_policy.c
>> and xfrm6_policy.c, sigh...
>=20
> Is there any progress in fixing this issue? I've seen this occasional=
ly
> on some of our production systems, so I fixed it for us in the meanti=
me
> with the patch below. I could submit this for inclusion if noone else
> wants to fix it in a different manner.
>=20
> ------
> net: Add a flow_cache_flush_deferred function
>=20
> flow_cach_flush() might sleep but can be called from
> atomic context via the xfrm garbage collector. So add
> a flow_cache_flush_deferred() function and use this if
> the xfrm garbage colector is invoked from within the
> packet path.
>=20
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Acked-by: Timo Ter=E4s <timo.teras@iki.fi>

I was first thinking if it made sense to run the local CPUs task
immediately on gc. But since all it does is queue the removed nodes to
the second gc that actually frees the dst's, it doesn't really make a
difference.

So this is probably as good as it gets.
