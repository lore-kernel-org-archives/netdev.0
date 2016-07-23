From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 14/14] ixgbe: cleanup crosstalk fix
Date: Sat, 23 Jul 2016 10:38:59 -0700
Message-ID: <1469295539.1900.166.camel@perches.com>
References: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1469256591-109822-15-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0142.hostedemail.com ([216.40.44.142]:57602 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751083AbcGWRjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2016 13:39:04 -0400
In-Reply-To: <1469256591-109822-15-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-07-22 at 23:49 -0700, Jeff Kirsher wrote:
> From: Don Skidmore <donald.c.skidmore@intel.com>
>=20
> This patch address a few issues with the initial crosstalk fix.=A0=A0=
Most
> important of which is the SDP that indicates the presents of a SFP+
> module changes between HW types.=A0=A0With this change that is taken =
in
> to consideration
[]
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/driver=
s/net/ethernet/intel/ixgbe/ixgbe_common.c
[]
> @@ -301,6 +302,22 @@ s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw)
> =A0	if (ret_val)
> =A0		return ret_val;
> =A0
> +	/* Cashe bit indicating need for crosstalk fix */

spello: cache

> +	switch (hw->mac.type) {
> +	case ixgbe_mac_82599EB:
> +	case ixgbe_mac_X550EM_x:
> +	case ixgbe_mac_x550em_a:
> +		hw->mac.ops.get_device_caps(hw, &device_caps);
> +		if (device_caps & IXGBE_DEVICE_CAPS_NO_CROSSTALK_WR)
> +			hw->need_crosstalk_fix =3D false;
> +		else
> +			hw->need_crosstalk_fix =3D true;

could be
		hw->need_crosstalk_fix =3D !(device_caps & IXGBE_DEVICE_CAPS_NO_CROSS=
TALK_WR);
