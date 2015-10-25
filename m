From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH] net/mlx4: Memcpy at slave_event should copy sizeof mlx4_eqe
Date: Sun, 25 Oct 2015 10:26:07 +0200
Message-ID: <CAJ3xEMiYZgGNqHffxDe4ixPECHwQ2cSbvVjHmjc49kROm=9p5g@mail.gmail.com>
References: <1445609940-12234-1-git-send-email-clsoto@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, brking@linux.vnet.ibm.com,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Yishai Hadas <yishaih@mellanox.com>
To: Carol L Soto <clsoto@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:36505 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbbJYI0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 04:26:09 -0400
Received: by igdg1 with SMTP id g1so40928476igd.1
        for <netdev@vger.kernel.org>; Sun, 25 Oct 2015 01:26:08 -0700 (PDT)
In-Reply-To: <1445609940-12234-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 23, 2015 at 4:19 PM,  <clsoto@linux.vnet.ibm.com> wrote:
> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>
> If the caps.eqe_size is bigger than the struct mlx4_eqe then there
> is a potential for corrupting data at the master context. We can see
> the message "Master failed to generate an EQE for slave: X" when the
> event_eqe array wraps and we can see potential oops at the function
> mlx4_GEN_EQE.
>
> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>

Hi Carol,

Does this fixes a specific commit? if yes, please add a Fixes: line
before your signature, maybe
one the changes to enable CQE/EQE striding introduced that?

43c816c67a53 net/mlx4_core: Cache line EQE size support
77507aa249ae net/mlx4_core: Enable CQE/EQE stride support

I also added Yishai and Jack who should review your fix

Or.



Or.

> ---
>  drivers/net/ethernet/mellanox/mlx4/eq.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
> index c344884..603d1c3 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/eq.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
> @@ -196,7 +196,7 @@ static void slave_event(struct mlx4_dev *dev, u8 slave, struct mlx4_eqe *eqe)
>                 return;
>         }
>
> -       memcpy(s_eqe, eqe, dev->caps.eqe_size - 1);
> +       memcpy(s_eqe, eqe, sizeof(struct mlx4_eqe) - 1);
>         s_eqe->slave_id = slave;
>         /* ensure all information is written before setting the ownersip bit */
>         dma_wmb();
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
