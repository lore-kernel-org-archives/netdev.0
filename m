From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sun, 4 Apr 2010 19:26:36 +0800
Message-ID: <20100404112636.GA11061@gondor.apana.org.au>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100404104230.GA10368@gondor.apana.org.au> <4BB86EE8.5090203@iki.fi> <20100404110014.GA10864@gondor.apana.org.au> <4BB872CF.2030202@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:50705 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752285Ab0DDL0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 07:26:39 -0400
Content-Disposition: inline
In-Reply-To: <4BB872CF.2030202@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 04, 2010 at 02:06:55PM +0300, Timo Ter=E4s wrote:
>
> It would still not work for policies. For every policy X we
> can get N+1 different matches with separate struct flowi contents.
> It's not possible to put single struct flowi or any other of
> the flow details in to xfrm_policy. It's a N-to-1 mapping. Not
> a 1-to-1 mapping.

=46ine, move key into flow_cache_entry but the rest should still
work, no?

struct flow_cache_object {
	u16			family;
	u8			dir;
	u32			genid;
	struct flow_cache_ops  *ops;
};

struct flow_cache_entry {
	struct flow_cache_entry	*next;
	struct flowi key;
	struct flow_cache_object *obj;
};

struct xfrm_policy {
	struct flow_cache_object flo;
	...
};

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
