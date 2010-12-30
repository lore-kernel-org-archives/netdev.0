From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 03/10] net/fec: add mac field into platform data and
 consolidate fec_get_mac
Date: Thu, 30 Dec 2010 10:12:44 +0800
Message-ID: <20101230021243.GA20155@freescale.com>
References: <1293548155-16328-1-git-send-email-shawn.guo@freescale.com>
 <1293548155-16328-4-git-send-email-shawn.guo@freescale.com>
 <20101229065329.GB31010@jasper.tkos.co.il>
 <20101229100520.GB19347@freescale.com>
 <20101229103138.GT14221@pengutronix.de>
 <20101229115808.GF19347@freescale.com>
 <20101229124220.GD14221@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Baruch Siach <baruch@tkos.co.il>, <davem@davemloft.net>,
	<gerg@snapgear.com>, <eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<lw@karo-electronics.de>, <w.sang@pengutronix.de>,
	<s.hauer@pengutronix.de>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe004.messaging.microsoft.com ([216.32.180.14]:36916
	"EHLO VA3EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754582Ab0L3CKn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Dec 2010 21:10:43 -0500
Received: from mail155-va3 (localhost.localdomain [127.0.0.1])	by
 mail155-va3-R.bigfish.com (Postfix) with ESMTP id 215931903AB	for
 <netdev@vger.kernel.org>; Thu, 30 Dec 2010 02:10:42 +0000 (UTC)
Received: from VA3EHSMHS033.bigfish.com (unknown [10.7.14.247])	by
 mail155-va3.bigfish.com (Postfix) with ESMTP id D8DEA1218052	for
 <netdev@vger.kernel.org>; Thu, 30 Dec 2010 02:10:41 +0000 (UTC)
Received: from az33smr01.freescale.net (az33smr01.freescale.net
 [10.64.34.199])	by de01egw01.freescale.net (8.14.3/8.14.3) with ESMTP id
 oBU2DUIT023202	for <netdev@vger.kernel.org>; Wed, 29 Dec 2010 19:13:30 -0700
 (MST)
Received: from ubuntu.localdomain (ubuntu-010192242196.ap.freescale.net
 [10.192.242.196])	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id
 oBU2AYsJ014343	for <netdev@vger.kernel.org>; Wed, 29 Dec 2010 20:10:34 -0600
 (CST)
Content-Disposition: inline
In-Reply-To: <20101229124220.GD14221@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Uwe,

On Wed, Dec 29, 2010 at 01:42:21PM +0100, Uwe Kleine-K=F6nig wrote:
> Hello Shawn,
>=20
> On Wed, Dec 29, 2010 at 07:58:09PM +0800, Shawn Guo wrote:
> > On Wed, Dec 29, 2010 at 11:31:38AM +0100, Uwe Kleine-K=F6nig wrote:
> > > On Wed, Dec 29, 2010 at 06:05:21PM +0800, Shawn Guo wrote:
> > > > On Wed, Dec 29, 2010 at 08:53:30AM +0200, Baruch Siach wrote:
> > > > 	if (iap =3D=3D fec_mac_default)
> > > > 		dev->dev_addr[ETH_ALEN-1] =3D fec_mac_default[ETH_ALEN-1] + f=
ep->pdev->id;
> > > Can this overflow?  (I didn't check the code, so my concern might=
 be
> > > completely stupid here.)
> > No. dev->dev_addr points to netdev_hw_addr->addr, which is a 32 byt=
es array.
> I didn't mean an out-of-bound access, but what is if
> fec_mac_default[ETH_ALEN-1] is 0xff and you add 1?  Does that result =
in
> 0x100 or 0?  What if id is <0?  For big ids you might even handle a
> carry to indixes <ETH_ALEN-2.
>=20
=46irst of all, all my patch did is changing fep->index to,
fep->pdev->id, which should not bring any problem you are concerned.

Secondly, I do not understand how the overflow on=20
fec_mac_default[ETH_ALEN-1] can result in a carry on the next array
element. Here is what I'm seeing with fec_mac=3D00:04:9f:01:30:ff.

eth0      Link encap:Ethernet  HWaddr 00:04:9F:01:30:FF
eth1      Link encap:Ethernet  HWaddr 00:04:9F:01:30:00

--=20
Regards,
Shawn

