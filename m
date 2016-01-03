From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH next] net/core/dev: Warn on an impossibly short offload
 frame
Date: Sat, 02 Jan 2016 17:06:33 -0800
Message-ID: <1451783193.4334.3.camel@perches.com>
References: <1451780713-4098-1-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>
To: Aaron Conole <aconole@bytheb.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0015.hostedemail.com ([216.40.44.15]:40163 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751056AbcACBGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2016 20:06:38 -0500
In-Reply-To: <1451780713-4098-1-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-01-02 at 19:25 -0500, Aaron Conole wrote:
> When signaling that a GRO frame is ready to be processed, the network=
 stack
> correctly checks length and aborts processing when a frame is less th=
an 14
> bytes. However, such a condition is really indicative of a broken dri=
ver,
> and should be loudly signaled, rather than silently dropped as the ca=
se is
> today.
>=20
> Convert the condition to use WARN_ON() to ensure that the stack loudl=
y
> complains about such broken drivers.
[]
> diff --git a/net/core/dev.c b/net/core/dev.c
[]
> @@ -4579,7 +4579,7 @@ static struct sk_buff *napi_frags_skb(struct na=
pi_struct *napi)
> =A0	eth =3D skb_gro_header_fast(skb, 0);
> =A0	if (unlikely(skb_gro_header_hard(skb, hlen))) {
> =A0		eth =3D skb_gro_header_slow(skb, hlen, 0);
> -		if (unlikely(!eth)) {
> +		if (WARN_ON(!eth)) {
> =A0			napi_reuse_skb(napi, skb);
> =A0			return NULL;
> =A0		}

It's generally a good idea to use
WARN_ON_RATELIMIT or WARN_ON_ONCE.
