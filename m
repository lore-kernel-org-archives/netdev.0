From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH] net: tulip: delete useless tests on netdev_priv
Date: Thu, 2 Jan 2014 07:57:26 -0800
Message-ID: <CAP6odjhqzKPiBdxQVm5BbbOFwiekJu66_WgSE+E4g_nkHh+-dQ@mail.gmail.com>
References: <1388680129-13661-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Grant Grundler <grundler@parisc-linux.org>,
	kernel-janitors@vger.kernel.org,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1388680129-13661-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 2, 2014 at 8:28 AM, Julia Lawall <Julia.Lawall@lip6.fr> wrote:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
>
> Netdev_priv performs an addition, not a pointer dereference, so it seems
> quit unlikely that its result would ever be NULL.

LGTM.

 >
> A semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
>
> // <smpl>
> @@
> statement S;
> @@
>
> - if (!netdev_priv(...)) S
> // </smpl>
>
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

cheers,
grant

>
> ---
>  drivers/net/ethernet/dec/tulip/uli526x.c |    6 ------
>  1 file changed, 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
> index a5397b1..aa4ee38 100644
> --- a/drivers/net/ethernet/dec/tulip/uli526x.c
> +++ b/drivers/net/ethernet/dec/tulip/uli526x.c
> @@ -1192,9 +1192,6 @@ static int uli526x_suspend(struct pci_dev *pdev, pm_message_t state)
>
>         ULI526X_DBUG(0, "uli526x_suspend", 0);
>
> -       if (!netdev_priv(dev))
> -               return 0;
> -
>         pci_save_state(pdev);
>
>         if (!netif_running(dev))
> @@ -1228,9 +1225,6 @@ static int uli526x_resume(struct pci_dev *pdev)
>
>         ULI526X_DBUG(0, "uli526x_resume", 0);
>
> -       if (!netdev_priv(dev))
> -               return 0;
> -
>         pci_restore_state(pdev);
>
>         if (!netif_running(dev))
>
