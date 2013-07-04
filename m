From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH V2 1/9] net/mlx5: Mellanox Connect-IB, core driver part 1/3
Date: Thu, 4 Jul 2013 16:26:44 +0300
Message-ID: <201307041626.45125.jackm@dev.mellanox.co.il>
References: <1372871592-32033-1-git-send-email-ogerlitz@mellanox.com> <1372871592-32033-2-git-send-email-ogerlitz@mellanox.com> <1372883397.1886.9.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, roland@kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, eli@dev.mellanox.co.il, moshel@mellanox.com,
	Eli Cohen <eli@mellanox.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:62195 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828Ab3GDNZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 09:25:07 -0400
Received: by mail-ee0-f42.google.com with SMTP id c4so773114eek.15
        for <netdev@vger.kernel.org>; Thu, 04 Jul 2013 06:25:06 -0700 (PDT)
In-Reply-To: <1372883397.1886.9.camel@joe-AO722>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 03 July 2013 23:29, Joe Perches wrote:
> On Wed, 2013-07-03 at 20:13 +0300, Or Gerlitz wrote:
> > From: Eli Cohen <eli@mellanox.com>
> 
> trivial comments:
> 
> > diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
> []
> > +static const char *deliv_status_to_str(u8 status)
> > +{
> > +	switch (status) {
> > +	case MLX5_CMD_DELIVERY_STAT_OK:
> > +		return "no errors";
> []
> > +	default:
> > +		return "unknown status code\n";
> > +	}
> > +}
> Likely unnecessary newline for default case
All the cases here have newlines between them, to enhance readability.
(not just the default). If you feel strongly about this, I'll do the change
for V3.

> > +static struct mlx5_cmd_mailbox *alloc_cmd_box(struct mlx5_core_dev *dev,
> > +					      gfp_t flags)
> > +{
> > +	struct mlx5_cmd_mailbox *mailbox;
> > +
> > +	mailbox = kmalloc(sizeof(*mailbox), flags);
> > +	if (!mailbox) {
> > +		mlx5_core_dbg(dev, "failed allocation\n");
> > +		return ERR_PTR(-ENOMEM);
> > +	}
> 
> unnecessary OOM message.

Will remove these kmalloc failure printouts in V3
> 
> > +static void set_wqname(struct mlx5_core_dev *dev)
> > +{
> > +	struct mlx5_cmd *cmd = &dev->cmd;
> > +
> > +	strcpy(cmd->wq_name, "mlx5_cmd_");
> > +	strcat(cmd->wq_name, dev_name(&dev->pdev->dev));
> 
> More likely snprintf might be better.
> 
> 	snprintf(cmd->wq_name, sizeof(cmd->wq_name), "mlx5_cmd_%s",
> 		 dev_name(&dev->pdev->dev));
> 
Will change this for V3
> How big is wq_name?
32 bytes. Should be enough to hold dev names. However, to be on the safe side
I'll do the change.

-Jack
