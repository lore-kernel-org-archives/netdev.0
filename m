From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: Refcount destination entry on xfrm_lookup
Date: Wed, 16 Mar 2011 10:03:23 +0200
Message-ID: <4D806ECB.4000205@iki.fi>
References: <20110316071249.GS31402@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56175 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365Ab1CPIDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 04:03:25 -0400
Received: by wya21 with SMTP id 21so1367767wya.19
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2011 01:03:24 -0700 (PDT)
In-Reply-To: <20110316071249.GS31402@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2011 09:12 AM, Steffen Klassert wrote:
> We return a destination entry without refcount if a socket
> policy is found in xfrm_lookup. This triggers a warning on
> a negative refcount when freeeing this dst entry. So take
> a refcount in this case to fix it.
>=20
> This refcount was forgotten when xfrm changed to cache bundles
> instead of policies for outgoing flows.
>=20
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Acked-by: Timo Ter=E4s <timo.teras@iki.fi>

Ok. This is one of the corner cases I did not test: having socket polic=
y
something else than no action. I just didn't have the application ready
for it. Sorry about the bug. And good catch Steffen.

> ---
>  net/xfrm/xfrm_policy.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 027e3c6..15792d8 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -1804,6 +1804,8 @@ restart:
>  				goto no_transform;
>  			}
> =20
> +			dst_hold(&xdst->u.dst);
> +
>  			spin_lock_bh(&xfrm_policy_sk_bundle_lock);
>  			xdst->u.dst.next =3D xfrm_policy_sk_bundles;
>  			xfrm_policy_sk_bundles =3D &xdst->u.dst;

