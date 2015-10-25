From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH] net/mlx4: Memcpy at slave_event should copy sizeof
 mlx4_eqe
Date: Sun, 25 Oct 2015 12:07:43 +0200
Message-ID: <20151025120743.3763b796@jpm-OptiPlex-GX620>
References: <1445609940-12234-1-git-send-email-clsoto@linux.vnet.ibm.com>
	<CAJ3xEMiYZgGNqHffxDe4ixPECHwQ2cSbvVjHmjc49kROm=9p5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Carol L Soto <clsoto@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, brking@linux.vnet.ibm.com,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:32993 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbbJYKHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 06:07:09 -0400
Received: by wijp11 with SMTP id p11so128521943wij.0
        for <netdev@vger.kernel.org>; Sun, 25 Oct 2015 03:07:08 -0700 (PDT)
In-Reply-To: <CAJ3xEMiYZgGNqHffxDe4ixPECHwQ2cSbvVjHmjc49kROm=9p5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Carol,

Good catch!

Need to add an additional chunk to your fix -- see below.

On Sun, 25 Oct 2015 10:26:07 +0200
Or Gerlitz <gerlitz.or@gmail.com> wrote:


> 
> > ---
> >  drivers/net/ethernet/mellanox/mlx4/eq.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c
> > b/drivers/net/ethernet/mellanox/mlx4/eq.c index c344884..603d1c3
> > 100644 --- a/drivers/net/ethernet/mellanox/mlx4/eq.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
> > @@ -196,7 +196,7 @@ static void slave_event(struct mlx4_dev *dev,
> > u8 slave, struct mlx4_eqe *eqe) return;
> >         }
> >
> > -       memcpy(s_eqe, eqe, dev->caps.eqe_size - 1);
> > +       memcpy(s_eqe, eqe, sizeof(struct mlx4_eqe) - 1);
> >         s_eqe->slave_id = slave;
> >         /* ensure all information is written before setting the
> > ownersip bit */ dma_wmb();

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 0a32020..2177e56 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2398,7 +2398,7 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 			}
 		}
 
-		memset(&priv->mfunc.master.cmd_eqe, 0, dev->caps.eqe_size);
+		memset(&priv->mfunc.master.cmd_eqe, 0, sizeof(struct mlx4_eqe));
 		priv->mfunc.master.cmd_eqe.type = MLX4_EVENT_TYPE_CMD;
 		INIT_WORK(&priv->mfunc.master.comm_work,
 			  mlx4_master_comm_channel);


> > --
> > 1.8.3.1
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
