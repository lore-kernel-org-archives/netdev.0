From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v3 05/10] net/fec: add dual fec support for mx28
Date: Fri, 7 Jan 2011 15:00:57 +0800
Message-ID: <20110107070056.GA28358@freescale.com>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
 <1294236457-17476-6-git-send-email-shawn.guo@freescale.com>
 <20110105163449.GU25121@pengutronix.de>
 <20110106041457.GC17891@freescale.com>
 <20110106071047.GW25121@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<lw@karo-electronics.de>, <w.sang@pengutronix.de>,
	<s.hauer@pengutronix.de>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:29320
	"EHLO VA3EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752060Ab1AGG6n convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jan 2011 01:58:43 -0500
Received: from mail116-va3 (localhost.localdomain [127.0.0.1])	by
 mail116-va3-R.bigfish.com (Postfix) with ESMTP id 106017702C7	for
 <netdev@vger.kernel.org>; Fri,  7 Jan 2011 06:58:41 +0000 (UTC)
Received: from VA3EHSMHS018.bigfish.com (unknown [10.7.14.236])	by
 mail116-va3.bigfish.com (Postfix) with ESMTP id D595A1390055	for
 <netdev@vger.kernel.org>; Fri,  7 Jan 2011 06:58:40 +0000 (UTC)
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw02.freescale.net (8.14.3/8.14.3) with ESMTP id p076waeS001446	for
 <netdev@vger.kernel.org>; Thu, 6 Jan 2011 23:58:38 -0700 (MST)
Received: from ubuntu.localdomain (ubuntu-010192242196.ap.freescale.net
 [10.192.242.196])	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id
 p076wZKe015257	for <netdev@vger.kernel.org>; Fri, 7 Jan 2011 00:58:35 -0600
 (CST)
Content-Disposition: inline
In-Reply-To: <20110106071047.GW25121@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Uwe,

On Thu, Jan 06, 2011 at 08:10:47AM +0100, Uwe Kleine-K=F6nig wrote:
> Hello Shawn,
>=20
[...]
> > > > +     /*
> > > > +      * enet-mac reset will reset mac address registers too,
> > > > +      * so need to reconfigure it.
> > > > +      */
> > > > +     if (fec_is_enetmac) {
> > > > +             memcpy(&temp_mac, dev->dev_addr, ETH_ALEN);
> > 		  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > > > +             writel(cpu_to_be32(temp_mac[0]), fep->hwp + FEC_A=
DDR_LOW);
> > > > +             writel(cpu_to_be32(temp_mac[1]), fep->hwp + FEC_A=
DDR_HIGH);
> > > where is the value saved to temp_mac[]?  For me it looks you writ=
e
> > > uninitialized data into the mac registers.
> >=20
> > memcpy above.
> oops.  right.  I looked for something like
>=20
> 	temp_mac[0] =3D dev->dev_addr[0] << $shiftfor0 | ...
>=20
> which AFAIK is what you want here.  memcpy is sensible to (at least)
> endian issues.  If you ask me factor out the setting of the mac addre=
ss
> in probe to a function and use that here, too.
>=20
The memcpy of mac address is being widely used in fec and other
network drivers, and I do not prefer to change something so common
in this patch set.

--=20
Regards,
Shawn

