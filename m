From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 03/16] fm10k: Avoid crashing the kernel
Date: Tue, 05 Apr 2016 01:13:55 -0700
Message-ID: <1459844035.1723.1.camel@perches.com>
References: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1459843288-40623-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0213.hostedemail.com ([216.40.44.213]:53715 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750946AbcDEIN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 04:13:58 -0400
In-Reply-To: <1459843288-40623-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-05 at 01:01 -0700, Jeff Kirsher wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
>=20
> Use BUILD_BUG_ON() instead of BUG_ON() where appropriate to get a com=
pile
> error rather than crash the kernel.
>=20
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Acked-by: Alexander Duyck <aduyck@mirantis.com>
> Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> =A0drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 4 ++--
> =A01 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drive=
rs/net/ethernet/intel/fm10k/fm10k_ethtool.c
> index 28837ae..6a9f988 100644
> --- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
> @@ -398,7 +398,7 @@ static void fm10k_get_reg_q(struct fm10k_hw *hw, =
u32 *buff, int i)
> =A0	buff[idx++] =3D fm10k_read_reg(hw, FM10K_TX_SGLORT(i));
> =A0	buff[idx++] =3D fm10k_read_reg(hw, FM10K_PFVTCTL(i));
> =A0
> -	BUG_ON(idx !=3D FM10K_REGS_LEN_Q);
> +	BUILD_BUG_ON(idx !=3D FM10K_REGS_LEN_Q);

idx is a variable.
Does this work on all compilers?

> =A0}
> =A0
> =A0/* If function above adds more registers this define needs to be u=
pdated */
> @@ -414,7 +414,7 @@ static void fm10k_get_reg_vsi(struct fm10k_hw *hw=
, u32 *buff, int i)
> =A0	for (j =3D 0; j < 32; j++)
> =A0		buff[idx++] =3D fm10k_read_reg(hw, FM10K_RETA(i, j));
> =A0
> -	BUG_ON(idx !=3D FM10K_REGS_LEN_VSI);
> +	BUILD_BUG_ON(idx !=3D FM10K_REGS_LEN_VSI);
> =A0}
> =A0
> =A0static void fm10k_get_regs(struct net_device *netdev,
