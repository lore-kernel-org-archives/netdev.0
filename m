From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net PATCH] tuntap: set SOCK_ZEROCOPY flag during open
Date: Sun, 9 Jun 2013 10:18:32 +0300
Message-ID: <20130609071817.GD13082@redhat.com>
References: <1370672261-30076-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1370672261-30076-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 08, 2013 at 02:17:41PM +0800, Jason Wang wrote:
> Commit 54f968d6efdbf7dec36faa44fc11f01b0e4d1990
> (tuntap: move socket to tun_file) forgets to set SOCK_ZEROCOPY flag, which will
> prevent vhost_net from doing zercopy w/ tap. This patch fixes this by setting
> it during file open.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

I see, and this explains the perf regression we are seeing with 3.9.

Acked-by: Michael S. Tsirkin <mst@redhat.com>

and I think this should go into stable as well.

> ---
>  drivers/net/tun.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index f042b03..d2ddd6d 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -2155,6 +2155,8 @@ static int tun_chr_open(struct inode *inode, struct file * file)
>  	set_bit(SOCK_EXTERNALLY_ALLOCATED, &tfile->socket.flags);
>  	INIT_LIST_HEAD(&tfile->next);
>  
> +	sock_set_flag(&tfile->sk, SOCK_ZEROCOPY);
> +
>  	return 0;
>  }
>  
> -- 
> 1.7.1
