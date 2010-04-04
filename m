From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sun, 4 Apr 2010 19:00:14 +0800
Message-ID: <20100404110014.GA10864@gondor.apana.org.au>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100404104230.GA10368@gondor.apana.org.au> <4BB86EE8.5090203@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:51278 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752815Ab0DDLAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 07:00:17 -0400
Content-Disposition: inline
In-Reply-To: <4BB86EE8.5090203@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 04, 2010 at 01:50:16PM +0300, Timo Ter=E4s wrote:
>
> Because flow_cache_entry is per-cpu, and multiple entries (due to
> different flows matching same policies, or same flow having multiple
> per-cpu entries) can point to same policy. If we cached "dummy" objec=
ts
> for even policies, then this would be better approach.

Oh yes of course.

But what we could do is embed most of flow_cache_entry into
xfrm_policy (and xdst in your latter patches) along with the
ops pointer.

Like this:

struct flow_cache_object {
	u16			family;
	u8			dir;
	u32			genid;
	struct flowi		key;
	struct flow_cache_ops **ops;
};

struct flow_cache_entry {
	struct flow_cache_entry	*next;
	struct flow_cache_object *obj;
};

struct xfrm_policy {
	struct flow_cache_object flo;
	...
};

What do you think?

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
