From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Wed, 21 Dec 2011 11:18:10 +0000
Message-ID: <1324466290.7877.22.camel@zakaz.uk.xensource.com>
References: <1323177878.2448.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1323264929.23681.178.camel@zakaz.uk.xensource.com>
	 <1323438427.20077.57.camel@zakaz.uk.xensource.com>
	 <20111209.133407.2156473837364120429.davem@davemloft.net>
	 <1324465434.7877.11.camel@zakaz.uk.xensource.com>
	 <1324465724.2728.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:60670 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262Ab1LULSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 06:18:12 -0500
In-Reply-To: <1324465724.2728.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-21 at 11:08 +0000, Eric Dumazet wrote:
> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:03 +0000, Ian Campbell a =
=C3=A9crit :
> > On Fri, 2011-12-09 at 18:34 +0000, David Miller wrote:
> > > From: Ian Campbell <Ian.Campbell@citrix.com>
> > > Date: Fri, 9 Dec 2011 13:47:07 +0000
> > >=20
> > > > If we had a concept like MAX_SKB_PAGES then it would perhaps ma=
ke
> > > > sense to have + 2 there, but AFAICT drivers etc are already
> > > > accounting for this appropriately by adding a further + 2 (or
> > > > sometimes + 1) to MAX_SKB_FRAGS.
> > >=20
> > > Any kind of code like this, including the "+ 2" in the skbuff hea=
der,
> > > should be coded to use some kind of macro so we can track this
> > > dependency instead of stumbling onto it and accidently breaking l=
ots
> > > of stuff if we want to change this "2" value.
> >=20
> > Agreed.
> >=20
> > Part of the problem is that no one seems to have any idea what this
> > particular + 2 means. My best hypothesis is that it accounts for th=
e
> > pages used by the linear area (which potentially crosses a page
> > boundary).
>=20
> I dont understand the point.

I did say hypothesis ;-) Do you know what that + 2 is actually all
about?

If no one knows what it is for maybe we should just remove it directly
instead of what I proposed?

> linear data is allocated with kmalloc(), so technically speaking its
> located in a single page, but page order can be 0, 1, 2, 3, ...
> MAX_ORDER.

I think I must misunderstand the terminology.

An order 1 allocation is in multiples of PAGE_SIZE, isn't it, even
though they happen to be contiguous?

Or are you considering the possibility of kmalloc returning a super pag=
e
of some description? Isn't that to some extent transparent to the calle=
r
who (assuming PAGE_SIZE 4096) doesn't know if kmalloc(16384) returned
4*4096 contiguous pages or 1*16384 page?

Anyway I take your underlying point that 2*PAGE_SIZE is no kind of limi=
t
on the size of the linear region.

Ian.
