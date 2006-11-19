From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 10/13] bcm43xx: update to new d80211 driver API
Date: Sun, 19 Nov 2006 20:43:10 +0100
Message-ID: <200611192043.11122.mb@bu3sch.de>
References: <1163802439.3392.47.camel@johannes.berg> <1163963898.15473.36.camel@johannes.berg> <1163964661.15473.59.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Ivo van Doorn <ivdoorn@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:6836
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S933079AbWKSTpQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 14:45:16 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1163964661.15473.59.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 19 November 2006 20:31, Johannes Berg wrote:

> --- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-11-19 20:12:47.629275208 +0100
> +++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-11-19 20:14:01.189275208 +0100
> @@ -285,7 +285,7 @@ void bcm43xx_debugfs_add_device(struct b
>  {
>  	struct bcm43xx_dfsentry *e;
>  	struct bcm43xx_txstatus_log *log;
> -	char devdir[IFNAMSIZ];
> +	char devdir[16];

What's the purpose of this?

>  	assert(bcm);
>  	e = kzalloc(sizeof(*e), GFP_KERNEL);
> @@ -308,7 +308,7 @@ void bcm43xx_debugfs_add_device(struct b
>  
>  	bcm->dfsentry = e;
>  
> -	strncpy(devdir, bcm->net_dev->name, ARRAY_SIZE(devdir));
> +	snprintf(devdir, sizeof(devdir), "wiphy%d", bcm->ieee->index);
>  	e->subdir = debugfs_create_dir(devdir, fs.root);
>  	e->dentry_tsf = debugfs_create_file("tsf", 0666, e->subdir,
>  	                                    bcm, &tsf_fops);

> +static struct ieee80211_ops bcm43xx_hw_ops = {
> +	.tx = bcm43xx_net_hard_start_xmit,
> +	.open = bcm43xx_net_open,
> +	.stop = bcm43xx_net_stop,
> +	.add_interface = bcm43xx_add_interface,
> +	.remove_interface = bcm43xx_remove_interface,
> +	.reset = bcm43xx_net_reset,
> +	.config = bcm43xx_net_config,
> +	.config_interface = bcm43xx_config_interface,
> +	.set_multicast_list = bcm43xx_set_multicast_list,
> +	.set_key = bcm43xx_net_set_key,
> +	.get_stats = bcm43xx_net_get_stats,
> +	.get_tx_stats = bcm43xx_net_get_tx_stats,
> +	.conf_tx = bcm43xx_net_conf_tx,
> +};

I like that being a seperate and static struct.

-- 
Greetings Michael.
