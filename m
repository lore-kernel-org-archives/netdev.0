From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: constify mdiobb_ops structures
Date: Mon, 16 Jan 2017 23:48:20 +0300
Message-ID: <c12e3f5b-7fa6-fa61-d18b-a4069026a014@cogentembedded.com>
References: <1484330546-16569-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Bhumika Goyal <bhumirks@gmail.com>, julia.lawall@lip6.fr,
        pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-renesas-soc@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484330546-16569-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 01/13/2017 09:02 PM, Bhumika Goyal wrote:

> Declare mdiobb_ops structures as const as they are only stored in the
> ops field of mdiobb_ctrl structures. This field is of type const, so
> mdiobb_ops structures having this property can be declared const too.
> Done using Coccinelle:

[...]

> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
[...]

> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 92d7692..1b0acd1 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -171,7 +171,7 @@ static int ravb_get_mdio_data(struct mdiobb_ctrl *ctrl)
>  }
>
>  /* MDIO bus control struct */
> -static struct mdiobb_ops bb_ops = {
> +static const struct mdiobb_ops bb_ops = {
>  	.owner = THIS_MODULE,
>  	.set_mdc = ravb_set_mdc,
>  	.set_mdio_dir = ravb_set_mdio_dir,
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 00fafab..6ef5dd8 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -1052,7 +1052,7 @@ static void sh_mdc_ctrl(struct mdiobb_ctrl *ctrl, int bit)
>  }
>
>  /* mdio bus control struct */
> -static struct mdiobb_ops bb_ops = {
> +static const struct mdiobb_ops bb_ops = {
>  	.owner = THIS_MODULE,
>  	.set_mdc = sh_mdc_ctrl,
>  	.set_mdio_dir = sh_mmd_ctrl,
[...]

    For the above 2 drivers:

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
