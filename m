From: Chunhui He <hchunhui@mail.ustc.edu.cn>
Subject: Re: [net-next] neigh: allow admin to set NUD_STALE
Date: Wed, 27 Jul 2016 12:25:13 +0000 (UTC)
Message-ID: <20160727.122513.1619464990432480392.hchunhui@mail.ustc.edu.cn>
References: <1469602610-6934-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ustc.edu.cn ([202.38.64.46]:54438 "EHLO ustc.edu.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753991AbcG0MZf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2016 08:25:35 -0400
In-Reply-To: <1469602610-6934-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 27 Jul 2016 09:56:50 +0300, Julian Anastasov <ja@ssi.bg> wrote:
> Admin should be able to set any state. Currently, this fails
> when lladdr is not changed and state is changed from
> NUD_CONNECTED to NUD_STALE:
> 
> ip neigh add 192.168.8.1 lladdr 00:11:22:33:44:55 nud perm dev wlan0
> ip neigh show to 192.168.8.1
> 192.168.8.1 dev wlan0 lladdr 00:11:22:33:44:55 PERMANENT
> ip neigh change 192.168.8.1 lladdr 00:11:22:33:44:55 nud stale dev wlan0
> ip neigh show to 192.168.8.1
> 192.168.8.1 dev wlan0 lladdr 00:11:22:33:44:55 PERMANENT
> 
> Problem may be from 2.1.X days.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/core/neighbour.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index cf26e04c4..2ae929f 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -1148,7 +1148,8 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
>  			} else
>  				goto out;
>  		} else {
> -			if (lladdr == neigh->ha && new == NUD_STALE)
> +			if (lladdr == neigh->ha && new == NUD_STALE &&
> +			    !(flags & NEIGH_UPDATE_F_ADMIN))
>  				new = old;
>  		}
>  	}

Reviewed-by: Chunhui He <hchunhui@mail.ustc.edu.cn>
