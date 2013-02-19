From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 13/15] ixgbe: implement SFF diagnostic monitoring via
 ethtool
Date: Tue, 19 Feb 2013 22:14:08 +0000
Message-ID: <1361312048.2967.44.camel@bwh-desktop.uk.solarflarecom.com>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1361003616-3422-14-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	=?ISO-8859-1?Q?Aur=E9lien?= Guillaume <footplus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49361 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933538Ab3BSWOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 17:14:24 -0500
In-Reply-To: <1361003616-3422-14-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-02-16 at 00:33 -0800, Jeff Kirsher wrote:
> From: Aur=C3=A9lien Guillaume <footplus@gmail.com>
>=20
> This patch adds support for reading data from SFP+ modules over i2c.
[...]
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
[...]
> +static int ixgbe_get_module_eeprom(struct net_device *dev,
> +					 struct ethtool_eeprom *ee,
> +					 u8 *data)
> +{
> +	struct ixgbe_adapter *adapter =3D netdev_priv(dev);
> +	struct ixgbe_hw *hw =3D &adapter->hw;
> +	u32 status =3D IXGBE_ERR_PHY_ADDR_INVALID;
> +	u8 databyte =3D 0xFF;
> +	int i =3D 0;
> +	int ret_val =3D 0;
> +
> +	/* ixgbe_get_module_info is called before this function in all
> +	 * cases, so we do not need any checks we already do above,
> +	 * and can trust ee->len to be a known value.
> +	 */
[...]

Whatever makes you think that?

All you are guaranteed is that:
    ee->offset <=3D ee->offset + ee->len <=3D eeprom_len
Same as for the regular EEPROM read function.

This implementation doesn't result in a heap overrun at present because
the caller allocates a whole page as a buffer.  But you should not
assume that it's safe to write more than ee->len bytes, nor that
ee->offset =3D=3D 0.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
