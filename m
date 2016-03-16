From: Gabriel Fernandez <gabriel.fernandez@linaro.org>
Subject: Re: [PATCH (net-next.git) 2/2] stmmac: fix MDIO settings
Date: Wed, 16 Mar 2016 12:01:06 +0100
Message-ID: <CAG374jDJS7TUSx0Ob38x4aRYHyrA+OWeCDm+f-Ytq8YZhwkEqg@mail.gmail.com>
References: <1458121942-5537-1-git-send-email-peppe.cavallaro@st.com> <1458121942-5537-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	=?UTF-8?Q?Andreas_F=C3=A4rber?= <afaerber@suse.de>,
	fschaefer.oss@googlemail.com, Dinh Nguyen <dinh.linux@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Phil Reid <preid@electromag.com.au>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37206 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966790AbcCPLBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 07:01:47 -0400
Received: by mail-wm0-f50.google.com with SMTP id p65so66611258wmp.0
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 04:01:47 -0700 (PDT)
In-Reply-To: <1458121942-5537-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pepe,

i have a kernel crash

[    2.714097] Unable to handle kernel NULL pointer dereference at
virtual address 000001d6
[    2.722188] pgd = c0204000
[    2.724886] [000001d6] *pgd=00000000
[    2.728452] Internal error: Oops: 5 [#1] SMP ARM
[    2.733054] Modules linked in:
[    2.736095] CPU: 1 PID: 1 Comm: swapper/0 Not tainted
4.5.0-rc7-01768-g3407893 #36
[    2.743649] Hardware name: STiH415/416 SoC with Flattened Device Tree
[    2.750074] task: ee070000 ti: ee05e000 task.ti: ee05e000
[    2.755467] PC is at stmmac_open+0xcc/0xc40
[    2.759641] LR is at of_phy_connect+0x44/0x5c


> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 4c5ce98..943500b 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -278,7 +278,6 @@ static void stmmac_eee_ctrl_timer(unsigned long arg)
>   */
>  bool stmmac_eee_init(struct stmmac_priv *priv)
>  {
> -       char *phy_bus_name = priv->plat->phy_bus_name;
>         unsigned long flags;
>         bool ret = false;
>
> @@ -290,7 +289,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
>                 goto out;
>
>         /* Never init EEE in case of a switch is attached */
> -       if (phy_bus_name && (!strcmp(phy_bus_name, "fixed")))
> +       if (priv->phydev->is_pseudo_fixed_link)

priv->phydev is not yet affected
replace by if (phydev->is_pseudo_fixed_link) instead ?


Best Regard

Gabriel
