From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] smsc95xx: support ethtool get_regs
Date: Fri, 6 Jul 2012 22:01:46 +0200
Message-ID: <20120706200146.GA11931@electric-eye.fr.zoreil.com>
References: <1291035348.223127.1341596173191.JavaMail.root@mail.savoirfairelinux.com> <1847398984.224080.1341598531284.JavaMail.root@mail.savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Glendinning <steve@shawell.net>,
	steve glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org, Nancy Lin <nancy.lin@smsc.com>
To: =?utf-8?Q?=C3=89meric?= Vigier
	<emeric.vigier@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54241 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261Ab2GFUN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 16:13:26 -0400
Content-Disposition: inline
In-Reply-To: <1847398984.224080.1341598531284.JavaMail.root@mail.savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=C3=89meric Vigier <emeric.vigier@savoirfairelinux.com> :
[...]
> +static int smsc95xx_ethtool_getregslen(struct net_device *dev)
> +{
> +	/* all smsc95xx registers plus all phy registers */
> +	return COE_CR - ID_REV + 1 + 32 * sizeof(u32);

I do not see where ID_REV is accounted for in the loops below.

s/32 */PHY_SPECIAL */ or s/PHY_SPECIAL/32/ below.

I thought PHY registers were 16 bits wide. Moreover they are already
available through smsc95xx_ioctl().

> +}
> +
> +static void
> +smsc95xx_ethtool_getregs(struct net_device *netdev, struct ethtool_r=
egs *regs,
> +			 void *buf)
> +{
> +	struct usbnet *dev =3D netdev_priv(netdev);
> +	unsigned int i, j =3D 0, retval;

	unsigned int i, j, retval;

> +	u32 *data =3D buf;
> +
> +	netif_dbg(dev, hw, dev->net, "ethtool_getregs\n");

The tracing framework does provide almost the same information.

> +
> +	retval =3D smsc95xx_read_reg(dev, ID_REV, &regs->version);
> +	if (retval < 0) {
> +		netdev_warn(dev->net, "REGS: cannot read ID_REV\n");

s/dev->net/netdev/ ?


> +		return;
> +	}
> +
> +	for (i =3D 0; i <=3D COE_CR; i +=3D (sizeof(u32))) {
> +		retval =3D smsc95xx_read_reg(dev, i, &data[j++]);

	for (i =3D 0, j =3D 0; i <=3D COE_CR; i +=3D sizeof(u32), j++) {
		retval =3D smsc95xx_read_reg(dev, i, data + j);

--=20
Ueimor
