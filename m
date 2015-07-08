From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 4.1 11/56] mvneta: add forgotten initialization of
 autonegotiation bits
Date: Wed, 8 Jul 2015 10:36:55 -0700
Message-ID: <20150708173655.GA16101@kroah.com>
References: <20150708073237.780280770@linuxfoundation.org>
 <20150708073238.389781888@linuxfoundation.org>
 <559D5996.5080506@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	Arnaud Ebalard <arno@natisbad.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, Stas Sergeev <stsp@users.sourceforge.net>,
	"David S. Miller" <davem@davemloft.net>,
	Sebastien Rannou <mxs@sbrk.org>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:34511 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758344AbbGHRg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 13:36:56 -0400
Content-Disposition: inline
In-Reply-To: <559D5996.5080506@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 08, 2015 at 08:10:46PM +0300, Stas Sergeev wrote:
> 08.07.2015 10:35, Greg Kroah-Hartman =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> >4.1-stable review patch.  If anyone has any objections, please let m=
e know.
> >
> >------------------
> >
> >From: Stas Sergeev <stsp@list.ru>
> >
> >[ Upstream commit 538761b794c1542f1c6e31eadd9d7aae118889f7 ]
> >
> >The commit 898b2970e2c9 ("mvneta: implement SGMII-based in-band link=
 state
> >signaling")
> >changed mvneta_adjust_link() so that it does not clear the auto-nego=
tiation
> >bits in MVNETA_GMAC_AUTONEG_CONFIG register. This was necessary for
> >auto-negotiation mode to work.
> >Unfortunately I haven't checked if these bits are ever initialized.
> >It appears they are not.
> >This patch adds the missing initialization of the auto-negotiation b=
its
> >in the MVNETA_GMAC_AUTONEG_CONFIG register.
> >It fixes the following regression:
> >https://www.mail-archive.com/netdev@vger.kernel.org/msg67928.html
> >
> >Since the patch was tested to fix a regression, it should be applied=
 to
> >stable tree.
> >
> >Tested-by: Arnaud Ebalard <arno@natisbad.org>
> >
> >CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> >CC: Florian Fainelli <f.fainelli@gmail.com>
> >CC: netdev@vger.kernel.org
> >CC: linux-kernel@vger.kernel.org
> >CC: stable@vger.kernel.org
> >
> >Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
> >Signed-off-by: David S. Miller <davem@davemloft.net>
> >Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> >---
> >  drivers/net/ethernet/marvell/mvneta.c |    6 ++++++
> >  1 file changed, 6 insertions(+)
> >
> >--- a/drivers/net/ethernet/marvell/mvneta.c
> >+++ b/drivers/net/ethernet/marvell/mvneta.c
> >@@ -1013,6 +1013,12 @@ static void mvneta_defaults_set(struct m
> >  		val =3D mvreg_read(pp, MVNETA_GMAC_CLOCK_DIVIDER);
> >  		val |=3D MVNETA_GMAC_1MS_CLOCK_ENABLE;
> >  		mvreg_write(pp, MVNETA_GMAC_CLOCK_DIVIDER, val);
> >+	} else {
> >+		val =3D mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
> >+		val &=3D ~(MVNETA_GMAC_INBAND_AN_ENABLE |
> >+		       MVNETA_GMAC_AN_SPEED_EN |
> >+		       MVNETA_GMAC_AN_DUPLEX_EN);
> >+		mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
> >  	}
> >  	mvneta_set_ucast_table(pp, -1);
> Hi Greg.
>=20
> Another problem was reported:
> https://lkml.org/lkml/2015/7/8/865
>=20
> So, while the above patch is correct and fixes what
> it should, the original patch has more problems to deal
> with. Maybe for stable it would be better to just revert
> the whole thing?

No, you will have to fix this in Linus's tree, right?  So I'll take the
patch that you get into there when that happens, I don't want to diverg=
e
from what is in that tree.

> I guess for stable I'll be posting the reverts instead of
> the above fix.

If you are reverting patches in Linus's tree, I'll take that as well.

thanks,

greg k-h
