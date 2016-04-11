From: Christian Daudt <csd-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] mwifiex: fix possible NULL dereference
Date: Mon, 11 Apr 2016 11:38:34 -0700
Message-ID: <CAHCK0=OX_bMoC=dwawmdSsMxk0cS3CxadqT5Y3QAUnSvgAHw+A@mail.gmail.com>
References: <1460388459-21090-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Sudip Mukherjee <sudip.mukherjee-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
To: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1460388459-21090-1-git-send-email-sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 11, 2016 at 8:27 AM, Sudip Mukherjee
<sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
> From: Sudip Mukherjee <sudip.mukherjee-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
>
> We have a check for card just after dereferencing it. So if it is NULL
> we have already dereferenced it before its check. Lets dereference it
> after checking card for NULL.
>
> Signed-off-by: Sudip Mukherjee <sudip.mukherjee-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
> ---
>  drivers/net/wireless/marvell/mwifiex/pcie.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/marvell/mwifiex/pcie.c b/drivers/net/wireless/marvell/mwifiex/pcie.c
> index edf8b07..84562d0 100644
> --- a/drivers/net/wireless/marvell/mwifiex/pcie.c
> +++ b/drivers/net/wireless/marvell/mwifiex/pcie.c
> @@ -2884,10 +2884,11 @@ static void mwifiex_unregister_dev(struct mwifiex_adapter *adapter)
>  {
>         struct pcie_service_card *card = adapter->card;
>         const struct mwifiex_pcie_card_reg *reg;
> -       struct pci_dev *pdev = card->dev;
> +       struct pci_dev *pdev;


you might want to move the variable declaration into the if block
below to avoid it being left undefined

>         int i;
>
>         if (card) {
> +               pdev = card->dev;


to here
  +                struct pci_dev pdev = card->dev;

>
>                 if (card->msix_enable) {
>                         for (i = 0; i < MWIFIEX_NUM_MSIX_VECTORS; i++)
>                                 synchronize_irq(card->msix_entries[i].vector);
>

cheers,
  csd
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
