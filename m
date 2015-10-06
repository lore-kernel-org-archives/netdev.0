From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH 2/2] Do not set shared_ports when nreq > MAX_MSIX
Date: Wed, 7 Oct 2015 00:39:56 +0300
Message-ID: <CAJ3xEMjYtmSj3kBo24w+4Y3Nh60C9J=NHb_=YQw1QASJ1i_i1g@mail.gmail.com>
References: <1444166829-17638-1-git-send-email-clsoto@linux.vnet.ibm.com>
	<1444166829-17638-2-git-send-email-clsoto@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, brking@linux.vnet.ibm.com
To: Carol L Soto <clsoto@linux.vnet.ibm.com>,
	Matan Barak <matanb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:32987 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752663AbbJFVj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 17:39:56 -0400
Received: by igbkq10 with SMTP id kq10so97749093igb.0
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 14:39:56 -0700 (PDT)
In-Reply-To: <1444166829-17638-2-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2015 at 12:27 AM,  <clsoto@linux.vnet.ibm.com> wrote:
> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>
> If we get MAX_MSIX interrupts would like to have each receive ring
> with his own msix interrupt line.

so 9293267a3e2a  was only partially correct? and/or not fully optimal?
please elaborate more on that in your change log.

>
> Fixes: 9293267a3e2a ('net/mlx4_core: Capping number of requested MSIXs to MAX_MSIX')
> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>

Carol, you didn't use net/mlx4: prefix as ask for mlx4 driver patch
titles, so please repost, but before that I'd like to see an ack from
Matan for this patch as well.

Or.

>
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index 006757f..f03f513 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2673,10 +2673,8 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
>
>                 nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
>                              nreq);
> -               if (nreq > MAX_MSIX) {
> +               if (nreq > MAX_MSIX)
>                         nreq = MAX_MSIX;
> -                       shared_ports = true;
> -               }
>
>                 entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
>                 if (!entries)
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
