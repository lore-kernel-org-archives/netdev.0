From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 9/10] d80211: rename master interface
Date: Fri, 21 Apr 2006 14:02:54 -0700
Message-ID: <20060421140254.65fe7d29@localhost.localdomain>
References: <20060421225314.048983000.midnight@suse.cz>
	<20060421205329.4059F482C0@silver.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15796 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932469AbWDUVC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 17:02:59 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060421205329.4059F482C0@silver.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Apr 2006 22:53:29 +0200 (CEST)
Jiri Benc <jbenc@suse.cz> wrote:

> Rename master interface to wmasterX to better reflect its purpose.
> 
> Signed-off-by: Jiri Benc <jbenc@suse.cz>
> 
> ---
> 
>  net/d80211/ieee80211.c   |    2 +-
>  net/d80211/ieee80211_i.h |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> 784f203467e4421aa0ecac34cb1647f4bdfe51be
> diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
> index 31f979c..1fd13dd 100644
> --- a/net/d80211/ieee80211.c
> +++ b/net/d80211/ieee80211.c
> @@ -4144,7 +4144,7 @@ struct net_device *ieee80211_alloc_hw(si
>  		((char *) local + ((sizeof(struct ieee80211_local) + 3) & ~3));
>  
>  	ether_setup(mdev);
> -	memcpy(mdev->name, "wlan%d", 7);
> +	memcpy(mdev->name, "wmaster%d", 10);

Why not use strlcpy or strncpy?  and use sizeof(mdev->name) or IFNAMSIZ
rather than hard coded 10.

>  
>  	local->dev_index = -1;
>  	local->mdev = mdev;
> diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
> index ea1d9ab..3580d1e 100644
> --- a/net/d80211/ieee80211_i.h
> +++ b/net/d80211/ieee80211_i.h
> @@ -318,7 +318,7 @@ #define IEEE80211_SUB_IF_TO_DEV(sub_if) 
>  struct ieee80211_local {
>  	struct ieee80211_hw *hw;
>  	void *hw_priv;
> -	struct net_device *mdev; /* wlan# - "master" 802.11 device */
> +	struct net_device *mdev; /* wmaster# - "master" 802.11 device */
>  	int open_count;
>  	int monitors;
>  	struct ieee80211_conf conf;
