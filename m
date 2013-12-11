From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: [PATCH RFC] mlx4_en: Add PTP hardware clock
Date: Wed, 11 Dec 2013 15:23:04 -0600
Message-ID: <20131211212304.GA8283@sbohrermbp13-local.rgmadvisors.com>
References: <1386786265-6322-1-git-send-email-shawn.bohrer@gmail.com>
 <CAJZOPZJF=uZWGeC_NMw4u+D6YxkmzNNwRQJ24whvvtNshxkx2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	tomk@rgmadvisors.com, Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:60871 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268Ab3LKVXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 16:23:23 -0500
Received: by mail-yh0-f47.google.com with SMTP id 29so5597227yhl.34
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 13:23:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJZOPZJF=uZWGeC_NMw4u+D6YxkmzNNwRQJ24whvvtNshxkx2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 11, 2013 at 10:47:51PM +0200, Or Gerlitz wrote:
> On Wed, Dec 11, 2013 Shawn Bohrer <shawn.bohrer@gmail.com> wrote:
> 
> > @@ -264,10 +267,6 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
> >         mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH)
> >                 mdev->port_cnt++;
> >
> > -       /* Initialize time stamp mechanism */
> > -       if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
> > -               mlx4_en_init_timestamp(mdev);
> > -
> >         mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
> >                 if (!dev->caps.comp_pool) {
> >                         mdev->profile.prof[i].rx_ring_num =
> > @@ -305,6 +304,10 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
> >                         mdev->pndev[i] = NULL;
> >         }
> >
> > +       /* Initialize time stamp mechanism */
> > +       if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
> > +               mlx4_en_init_timestamp(mdev);
> > +
> >         return mdev;
> 
> so you are reverting here commit 1ec4864b1017 "net/mlx4_en: Fixed
> crash when port type is changed" -- why?

For stupid reasons.  I'm using mdev->pndev[i]->perm_addr to initialize
the ptp_clock_info.name field in mlx4_en_init_timestamp().  I'll look
around and see if I can find something better to use and put this
back.

--
Shawn
