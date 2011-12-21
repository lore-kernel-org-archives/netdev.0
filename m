From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Wed, 21 Dec 2011 12:08:44 +0100
Message-ID: <1324465724.2728.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1323177878.2448.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1323264929.23681.178.camel@zakaz.uk.xensource.com>
	 <1323438427.20077.57.camel@zakaz.uk.xensource.com>
	 <20111209.133407.2156473837364120429.davem@davemloft.net>
	 <1324465434.7877.11.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:43079 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909Ab1LULIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 06:08:47 -0500
Received: by vcbfk14 with SMTP id fk14so5630611vcb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 03:08:47 -0800 (PST)
In-Reply-To: <1324465434.7877.11.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:03 +0000, Ian Campbell a =C3=
=A9crit :
> On Fri, 2011-12-09 at 18:34 +0000, David Miller wrote:
> > From: Ian Campbell <Ian.Campbell@citrix.com>
> > Date: Fri, 9 Dec 2011 13:47:07 +0000
> >=20
> > > If we had a concept like MAX_SKB_PAGES then it would perhaps make
> > > sense to have + 2 there, but AFAICT drivers etc are already
> > > accounting for this appropriately by adding a further + 2 (or
> > > sometimes + 1) to MAX_SKB_FRAGS.
> >=20
> > Any kind of code like this, including the "+ 2" in the skbuff heade=
r,
> > should be coded to use some kind of macro so we can track this
> > dependency instead of stumbling onto it and accidently breaking lot=
s
> > of stuff if we want to change this "2" value.
>=20
> Agreed.
>=20
> Part of the problem is that no one seems to have any idea what this
> particular + 2 means. My best hypothesis is that it accounts for the
> pages used by the linear area (which potentially crosses a page
> boundary).

I dont understand the point.

linear data is allocated with kmalloc(), so technically speaking its
located in a single page, but page order can be 0, 1, 2, 3, ...
MAX_ORDER.
