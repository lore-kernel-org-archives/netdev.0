From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] wireless-dev: relax sysfs permissions
Date: Tue, 22 Aug 2006 16:47:40 +0200
Message-ID: <20060822164740.51861395@griffin.suse.cz>
References: <1155736186.3600.29.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42159 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932284AbWHVOrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 10:47:43 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1155736186.3600.29.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 16 Aug 2006 15:49:45 +0200, Johannes Berg wrote:
> The sysfs attributes add_iface and remove_iface both check for
> CAP_NET_ADMIN whenever something is written. Hence, permissions for the
> files should be relaxed so that someone who is not root but happens to
> have CAP_NET_ADMIN can do things.

I'm not sure about this. Greg, what's the policy here?

Note that there is also another way for adding and removing interfaces -
via nl80211 netlink interface (not finished yet but will go in shortly).

> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> 
> --- wireless-dev.orig/net/d80211/ieee80211_sysfs.c	2006-08-16 15:45:41.000000000 +0200
> +++ wireless-dev/net/d80211/ieee80211_sysfs.c	2006-08-16 15:46:05.000000000 +0200
> @@ -195,8 +195,8 @@
>  __IEEE80211_LOCAL_SHOW(rate_ctrl_alg);
>  
>  static struct class_device_attribute ieee80211_class_dev_attrs[] = {
> -	__ATTR(add_iface, S_IWUSR, NULL, store_add_iface),
> -	__ATTR(remove_iface, S_IWUSR, NULL, store_remove_iface),
> +	__ATTR(add_iface, S_IWUGO, NULL, store_add_iface),
> +	__ATTR(remove_iface, S_IWUGO, NULL, store_remove_iface),
>  	__ATTR(channel, S_IRUGO, ieee80211_local_show_channel, NULL),
>  	__ATTR(frequency, S_IRUGO, ieee80211_local_show_frequency, NULL),
>  	__ATTR(radar_detect, S_IRUGO, ieee80211_local_show_radar_detect, NULL),
> 
> 

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
