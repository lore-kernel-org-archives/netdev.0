From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH] net/mlx4_core: pass pci_dev_data to __mlx4_init_one
Date: Mon, 24 Mar 2014 08:40:42 +0200
Message-ID: <CAJZOPZLM+fRBqA_rkgiUO5FCd1YtzsCKN3=denHW6Tx7OHN6RQ@mail.gmail.com>
References: <1395636171-17347-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:49794 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbaCXGkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 02:40:43 -0400
Received: by mail-pb0-f54.google.com with SMTP id ma3so5003980pbc.41
        for <netdev@vger.kernel.org>; Sun, 23 Mar 2014 23:40:42 -0700 (PDT)
In-Reply-To: <1395636171-17347-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 24, 2014 at 6:42 AM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>
> The second parameter of __mlx4_init_one() is used to identify whether the
> pci_dev is a PF or VF. Currently, when it is invoked in mlx4_pci_slot_reset()
> this information is missed.


This patch isn't fixing something in 3.14, right? if this is the case
I assume it's for net-next, please put a "net" or "net-next"
indication (next-time)

Or.

>
>
> This patch passes the pci_dev_data to __mlx4_init_one().
>
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c |    8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index d711158..9ffce06 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2670,7 +2670,13 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
>
>  static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
>  {
> -       int ret = __mlx4_init_one(pdev, 0);
> +       int ret;
> +       struct mlx4_dev  *dev  = pci_get_drvdata(pdev);
> +       struct mlx4_priv *priv = mlx4_priv(dev);
> +       int               pci_dev_data;
> +
> +       pci_dev_data = priv->pci_dev_data;
> +       ret = __mlx4_init_one(pdev, pci_dev_data);
>
>         return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
>  }
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
