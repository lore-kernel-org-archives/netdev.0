From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [XFRM]: constify 'struct xfrm_type'
Date: Thu, 24 Jan 2008 20:24:17 +0100
Message-ID: <4798E5E1.9050408@cosmosbay.com>
References: <20080124122621.3248c651.dada1@cosmosbay.com>	 <1201195057.16268.32.camel@localhost>  <4798D7B9.5090406@cosmosbay.com> <1201199858.16268.46.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604003av.neufgp.fr ([84.96.92.124]:37838
	"EHLO neuf-infra-smtp-out-sp604003av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752580AbYAXTYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 14:24:22 -0500
In-Reply-To: <1201199858.16268.46.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches a =E9crit :
> On Thu, 2008-01-24 at 19:23 +0100, Eric Dumazet wrote:
>> Having const data is nice because moving them from .data to .rodata,
>> but what would be practical gains to use a const pointer ???
>=20
> const data is good, using pointers to const data is good.

Yes, this is what is done.

> using const pointers to const data is good.

const pointers are seldom used in linux kernel, because mostly useless.

> using const pointers to data not specified as const is not so good.

You misread the patch. I am not using const pointers at all, but const =
data.



>=20
> Here's what you are doing now.
>=20
> +static void xfrm_put_type(const struct xfrm_type *type)
> [...]
> +	const struct xfrm_type *type;
>=20

Yes, this was the plan, I meant it.

I still dont understand what *you* want to do.

Doing :

int xfrm_unregister_type(const struct xfrm_type * const type, const uns=
igned=20
short family)

instead of :

int xfrm_unregister_type(const struct xfrm_type *type, unsigned short f=
amily)

buys nothing for the caller.


