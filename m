From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v3 08/10] ARM: mxs: add ocotp read function
Date: Thu, 6 Jan 2011 09:45:19 +0800
Message-ID: <20110106014518.GA17891@freescale.com>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
 <1294236457-17476-9-git-send-email-shawn.guo@freescale.com>
 <20110105161235.GA2112@gallagher>
 <20110105164409.GV25121@pengutronix.de>
 <20110105172501.GB2112@gallagher>
 <20110105175617.GD12222@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamie Iles <jamie@jamieiles.com>,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, <gerg@snapgear.com>,
	<B32542@freescale.com>, <netdev@vger.kernel.org>,
	<s.hauer@pengutronix.de>, <baruch@tkos.co.il>,
	<w.sang@pengutronix.de>, <r64343@freescale.com>,
	<linux-arm-kernel@lists.infradead.org>, <eric@eukrea.com>,
	<bryan.wu@canonical.com>, <davem@davemloft.net>,
	<lw@karo-electronics.de>
To: Jamie Lokier <jamie@shareable.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:11955 "EHLO
	TX2EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751906Ab1AFBnI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jan 2011 20:43:08 -0500
Received: from mail50-tx2 (localhost.localdomain [127.0.0.1])	by
 mail50-tx2-R.bigfish.com (Postfix) with ESMTP id 53EA46E0103	for
 <netdev@vger.kernel.org>; Thu,  6 Jan 2011 01:43:07 +0000 (UTC)
Received: from TX2EHSMHS040.bigfish.com (unknown [10.9.14.243])	by
 mail50-tx2.bigfish.com (Postfix) with ESMTP id EC029109004F	for
 <netdev@vger.kernel.org>; Thu,  6 Jan 2011 01:43:06 +0000 (UTC)
Received: from az33smr01.freescale.net (az33smr01.freescale.net
 [10.64.34.199])	by az33egw02.freescale.net (8.14.3/8.14.3) with ESMTP id
 p061h4Nv008612	for <netdev@vger.kernel.org>; Wed, 5 Jan 2011 18:43:04 -0700
 (MST)
Received: from ubuntu.localdomain (ubuntu-010192242196.ap.freescale.net
 [10.192.242.196])	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id
 p061h3Od021344	for <netdev@vger.kernel.org>; Wed, 5 Jan 2011 19:43:04 -0600
 (CST)
Content-Disposition: inline
In-Reply-To: <20110105175617.GD12222@shareable.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 05, 2011 at 05:56:17PM +0000, Jamie Lokier wrote:
> Jamie Iles wrote:
> > On Wed, Jan 05, 2011 at 05:44:09PM +0100, Uwe Kleine-K=F6nig wrote:
> > > Hello Jamie,
> > > On Wed, Jan 05, 2011 at 04:16:46PM +0000, Jamie Iles wrote:
> > > > On Wed, Jan 05, 2011 at 10:07:35PM +0800, Shawn Guo wrote:
> > > > > +	/* check both BUSY and ERROR cleared */
> > > > > +	while ((__raw_readl(ocotp_base) &
> > > > > +		(BM_OCOTP_CTRL_BUSY | BM_OCOTP_CTRL_ERROR)) && --timeout)
> > > > > +		/* nothing */;
> > > >=20
> > > > Is it worth using cpu_relax() in these polling loops?
> > > I don't know what cpu_relax does for other platforms, but on ARM =
it's
> > > just a memory barrier which AFAICT doesn't help here at all (whic=
h
> > > doesn't need to be correct).  Why do you think it would be better=
?
> >=20
> > Well I don't see that there's anything broken without cpu_relax() b=
ut=20
> > using cpu_relax() seems to be the most common way of doing busy pol=
ling=20
> > loops that I've seen. It's also a bit easier to read than a comment=
 and=20
> > semi-colon. Perhaps it's just personal preference.
>=20
> cpu_relax() is a hint to the CPU to, for example, save power or be
> less aggressive on the memory bus (to save power or be fairer).
>=20
> Currently these architectures do more than just a barrier in cpu_rela=
x():
> x86, IA64, PowerPC, Tile and S390.
>=20
> Although it's just a hint on ARM at the moment, it might change in
> future - especially with power mattering on so many ARM systems.
> (Even now, just changing it to a very short udelay might save power
> on existing ARMs without breaking drivers.)
>=20
Sounds reasonable.  I would take the suggestion.  Thanks, both Jamie.

--=20
Regards,
Shawn

