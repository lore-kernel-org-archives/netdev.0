From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: RE: Possible issue with Mellanox mlx4/port handling
Date: Mon, 3 Sep 2012 17:32:40 +0000
Message-ID: <953B660C027164448AE903364AC447D28720CF7D@MTLDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "mleitner@redhat.com" <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:59903 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753285Ab2ICRcp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 13:32:45 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Commit
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=4c41b3673759d096106e68bce586f103c51d4119
> inserted changes like:
> 
> @@ -361,7 +361,7 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8
> port,
>          int err;
>          struct mlx4_priv *priv = mlx4_priv(dev);
> 
> -       s_steer = &mlx4_priv(dev)->steer[0];
> +       s_steer = &mlx4_priv(dev)->steer[port - 1];
> 
>          mutex_lock(&priv->mcg_table.mutex);
> 
> But I fear we missed one part of the deal. Concept patch:
> 
> @@ -365,7 +365,7 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8
> port,
> 
>          mutex_lock(&priv->mcg_table.mutex);
> 
> -       if (get_promisc_qp(dev, 0, steer, qpn)) {
> +       if (get_promisc_qp(dev, port - 1, steer, qpn)) {
>                  err = 0;  /* Noting to do, already exists */
>                  goto out_mutex;
>          }
> 
...
> 
> As far as I can understand, we are changing a list for a port and checking for
> duplicates on the other list. Points marked as A, B and C for highlighting. Am I
> missing something? What do you think?
> 
> FWIW, this call get_promisc_qp(dev, 0, ...) happens in other places too.
> 
> Thank you,
> Marcelo.

Hi Marcelo,
Thanks for this, You are absolutely right.
We actually have a fix for this issue which we are now verifying, and it will be sent to the mailing list in a few days.

Thanks,
Yevgeny
