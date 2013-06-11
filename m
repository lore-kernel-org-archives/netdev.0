From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net PATCH] tuntap: set SOCK_ZEROCOPY flag during open
Date: Tue, 11 Jun 2013 16:17:50 +0300
Message-ID: <20130611131750.GD9279@redhat.com>
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
>Cc: smtp.corp.redhat.com@redhat.com, davem@davemloft.net,
>	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
>
> Commit 54f968d6efdbf7dec36faa44fc11f01b0e4d1990
> (tuntap: move socket to tun_file) forgets to set SOCK_ZEROCOPY flag, which will
> prevent vhost_net from doing zercopy w/ tap. This patch fixes this by setting
> it during file open.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

One of the addresses in the Cc list (smtp.corp.redhat.com@redhat.com)
is clearly a mistake, which probably explains why it didn't
get into patchwork.

I have bounced it to correct addresses, hope this
helps instead of making even more of a mess of it.

For 3.10 and -stable:

Acked-by: Michael S. Tsirkin <mst@redhat.com>


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
