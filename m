From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Compile-time warnings on mlx4/net-next
Date: Fri, 16 Jan 2015 04:54:14 -0800
Message-ID: <1421412854.11734.118.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54B7BB17.8090308@redhat.com> <54B7BEAF.6000406@mellanox.com>
	 <54B7C2EB.8010007@redhat.com> <54B8F9D6.4050202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:50828 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbbAPMyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 07:54:16 -0500
Received: by mail-ig0-f174.google.com with SMTP id hn15so3188288igb.1
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 04:54:15 -0800 (PST)
In-Reply-To: <54B8F9D6.4050202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-16 at 12:45 +0100, Daniel Borkmann wrote:
> On 01/15/2015 02:38 PM, Marcelo Ricardo Leitner wrote:
> > On 15-01-2015 11:20, Or Gerlitz wrote:
> ...
> >>> Do you see them too?
> >>
> >> using $ make W=1 -j 20 SUBDIRS=./drivers/net/ethernet/mellanox/mlx4 with gcc
> >> 4.8.2 I don't see that, but I'll look there,
> >> thanks for the report.
> 
> I believe they are there for quite some time already. I'm using gcc 4.8.3
> and just default build. I'm surprised Fengguang didn't complain yet (or
> he did, but it got ignored somehow ;)). The following should be sufficient
> to just shut gcc up:
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
> index 982861d..b01154d 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/fw.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
> @@ -2122,6 +2122,7 @@ int mlx4_config_dev_retrieval(struct mlx4_dev *dev,
>   	if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_CONFIG_DEV))
>   		return -ENOTSUPP;
> 
> +	memset(&config_dev, 0, sizeof(config_dev));
>   	err = mlx4_CONFIG_DEV_get(dev, &config_dev);
>   	if (err)
>   		return err;

Yeah, I reported the same issue some time back.
