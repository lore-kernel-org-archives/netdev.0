From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 14/30] net: Kill some unneeded allocation return value
	casts in libertas
Date: Fri, 24 Aug 2007 11:50:24 -0400
Message-ID: <1187970624.20110.0.camel@xo-13-A4-25.localdomain>
References: <1554af80879a7ef2f78a4d654f23c248203500d9.1187912217.git.jesper.juhl@gmail.com>
	 <2ac91f5f0eed967cf1709cfbe476b351e536c299.1187912217.git.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jesper Juhl <jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2ac91f5f0eed967cf1709cfbe476b351e536c299.1187912217.git.jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-08-24 at 02:03 +0200, Jesper Juhl wrote:
> kmalloc() and friends return void*, no need to cast it.

Applied to libertas-2.6 'for-linville' branch, thanks.

Dan

> Signed-off-by: Jesper Juhl <jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/wireless/libertas/debugfs.c |    2 +-
>  drivers/net/wireless/libertas/ethtool.c |    3 +--
>  2 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
> index 715cbda..6ade63e 100644
> --- a/drivers/net/wireless/libertas/debugfs.c
> +++ b/drivers/net/wireless/libertas/debugfs.c
> @@ -1839,7 +1839,7 @@ static ssize_t wlan_debugfs_write(struct file *f, const char __user *buf,
>  	char *p2;
>  	struct debug_data *d = (struct debug_data *)f->private_data;
>  
> -	pdata = (char *)kmalloc(cnt, GFP_KERNEL);
> +	pdata = kmalloc(cnt, GFP_KERNEL);
>  	if (pdata == NULL)
>  		return 0;
>  
> diff --git a/drivers/net/wireless/libertas/ethtool.c b/drivers/net/wireless/libertas/ethtool.c
> index 96f1974..7dad493 100644
> --- a/drivers/net/wireless/libertas/ethtool.c
> +++ b/drivers/net/wireless/libertas/ethtool.c
> @@ -60,8 +60,7 @@ static int libertas_ethtool_get_eeprom(struct net_device *dev,
>  
>  //      mutex_lock(&priv->mutex);
>  
> -	adapter->prdeeprom =
> -		    (char *)kmalloc(eeprom->len+sizeof(regctrl), GFP_KERNEL);
> +	adapter->prdeeprom = kmalloc(eeprom->len+sizeof(regctrl), GFP_KERNEL);
>  	if (!adapter->prdeeprom)
>  		return -ENOMEM;
>  	memcpy(adapter->prdeeprom, &regctrl, sizeof(regctrl));
