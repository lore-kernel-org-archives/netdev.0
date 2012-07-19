From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] tun: don't zeroize sock->file on detach
Date: Thu, 19 Jul 2012 08:06:38 +0200
Message-ID: <1342677998.2626.3844.camel@edumazet-glaptop>
References: <20120711114753.24395.53193.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ruanzhijie@hotmail.com, linux-kernel@vger.kernel.org
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:34218 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab2GSGGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 02:06:43 -0400
In-Reply-To: <20120711114753.24395.53193.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-11 at 15:48 +0400, Stanislav Kinsbursky wrote:
> This is a fix for bug, introduced in 3.4 kernel by commit
> 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d, which, among other things, replaced
> simple sock_put() by sk_release_kernel(). Below is sequence, which leads to
> oops for non-persistent devices:
> 
> tun_chr_close()
> tun_detach()				<== tun->socket.file = NULL
> tun_free_netdev()
> sk_release_sock()
> sock_release(sock->file == NULL)
> iput(SOCK_INODE(sock))			<== dereference on NULL pointer
> 
> This patch just removes zeroing of socket's file from __tun_detach().
> sock_release() will do this.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> ---
>  drivers/net/tun.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 987aeef..c1639f3 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -185,7 +185,6 @@ static void __tun_detach(struct tun_struct *tun)
>  	netif_tx_lock_bh(tun->dev);
>  	netif_carrier_off(tun->dev);
>  	tun->tfile = NULL;
> -	tun->socket.file = NULL;
>  	netif_tx_unlock_bh(tun->dev);
>  
>  	/* Drop read queue */
> 

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
