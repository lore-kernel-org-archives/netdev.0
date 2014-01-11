From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH net,stable] net: usbnet: fix SG initialisation
Date: Sat, 11 Jan 2014 17:16:52 +0800
Message-ID: <CACVXFVPbi47ZLWm-AMeX1NLp3_BQWRSuWz7YjTXz-z3JmVoyRA@mail.gmail.com>
References: <1389391817-27204-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Thomas Kear <thomas@kear.co.nz>,
	Ben Hutchings <bhutchings@solarflare.com>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:38670 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbaAKJQy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 04:16:54 -0500
In-Reply-To: <1389391817-27204-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 11, 2014 at 6:10 AM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Commit 60e453a940ac ("USBNET: fix handling padding packet")
> added an extra SG entry in case padding is necessary, but
> failed to update the initialisation of the list. This can
> cause list traversal to fall off the end of the list,
> resulting in an oops.
>
> Fixes: 60e453a940ac ("USBNET: fix handling padding packet")
> Reported-by: Thomas Kear <thomas@kear.co.nz>
> Cc: Ming Lei <ming.lei@canonical.com>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
> ---
> I don't have the hardware to verify this fix.  It would be good if
> someone could test it before it goes to stable...
>
> But in case this works, it should go into v3.12 stable.

Yes, the problem can only be triggered when the zlp padding
packet is needed, I remember I have a quick approach to
reproduce and test the case, and I will do it when I return
home tonight.

Looks the fix is correct, and sorry for introducing the issue.

>
>
> Bj=F8rn
>
>  drivers/net/usb/usbnet.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 8494bb53ebdc..aba04f561760 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -1245,7 +1245,7 @@ static int build_dma_sg(const struct sk_buff *s=
kb, struct urb *urb)
>                 return -ENOMEM;
>
>         urb->num_sgs =3D num_sgs;
> -       sg_init_table(urb->sg, urb->num_sgs);
> +       sg_init_table(urb->sg, urb->num_sgs + 1);
>
>         sg_set_buf(&urb->sg[s++], skb->data, skb_headlen(skb));
>         total_len +=3D skb_headlen(skb);

Thanks,
--
Ming Lei
