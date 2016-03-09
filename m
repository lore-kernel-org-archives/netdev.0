From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH (net.git) 2/2] stmmac: fix MDIO settings
Date: Wed, 9 Mar 2016 15:39:27 +0100
Message-ID: <20160309143927.GD31963@lunn.ch>
References: <1457514007-32333-1-git-send-email-peppe.cavallaro@st.com>
 <1457514007-32333-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gabriel.fernandez@linaro.org,
	afaerber@suse.de, fschaefer.oss@googlemail.com,
	dinh.linux@gmail.com, davem@davemloft.net
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53350 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752566AbcCIOjc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 09:39:32 -0500
Content-Disposition: inline
In-Reply-To: <1457514007-32333-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 09, 2016 at 10:00:07AM +0100, Giuseppe Cavallaro wrote:
> Initially the phy_bus_name was added to manipulate the
> driver name but It was recently just used to manage the
> fixed-link and then to take some decision at run-time
> inside the main (for example to skip EEE).
>=20
> So the patch now introduces a new platforms boolean to
> manage that and removes the phy_bus_name variable not
> necessary anymore.
>=20
> The driver can manage the mdio registration by using phy-handle,
> dwmac-mdio and own parameter e.g. snps,phy-addr.
> This patch takes care about all these possible configurations
> and fixes the mdio registration in case of there is a real
> transceiver or a switch (that needs to be managed by using
> fixed-link).
>=20
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Gabriel Fernandez <gabriel.fernandez@linaro.org>
> Cc: Andreas F=E4rber <afaerber@suse.de>
> Cc: Frank Sch=E4fer <fschaefer.oss@googlemail.com>
> Cc: Dinh Nguyen <dinh.linux@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   11 +++-------=
-
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   15 ++++++----=
-----
>  include/linux/stmmac.h                             |    2 +-
>  3 files changed, 10 insertions(+), 18 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driv=
ers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index c21015b..87e4643 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -271,7 +271,6 @@ static void stmmac_eee_ctrl_timer(unsigned long a=
rg)
>   */
>  bool stmmac_eee_init(struct stmmac_priv *priv)
>  {
> -	char *phy_bus_name =3D priv->plat->phy_bus_name;
>  	unsigned long flags;
>  	bool ret =3D false;
> =20
> @@ -283,7 +282,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
>  		goto out;
> =20
>  	/* Never init EEE in case of a switch is attached */
> -	if (phy_bus_name && (!strcmp(phy_bus_name, "fixed")))
> +	if (priv->plat->is_fixed_link)
>  		goto out;

Hi Giuseppe

The phydev itself has a bool is_pseudo_fixed_link. You might be able
to use this instead of adding your own.

   Andrew
