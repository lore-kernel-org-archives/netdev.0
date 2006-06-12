From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 3/12] d80211: separate allocation of ieee80211_local
Date: Mon, 12 Jun 2006 21:35:23 +0200
Message-ID: <20060612213523.473a9714@griffin.suse.cz>
References: <20060608094822.014829000.midnight@suse.cz>
	<20060608074907.2CB5B48391@silver.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:26041 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1752250AbWFLTf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 15:35:28 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060608074907.2CB5B48391@silver.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu,  8 Jun 2006 09:49:07 +0200 (CEST), Jiri Benc wrote:
> ieee80211_local has a separate class_device. That means it has reference
> counting independent of master net_device and can be freed at a different
> time, therefore these two structures cannot be allocated together.
> 
> Solve this by adding ieee80211_ptr pointer to net_device structure (similar
> to other pointers already presented there) and using it as a pointer to
> independently allocated ieee80211_local.

I suppose approval from Dave will be needed for adding that pointer to
net_device, right?

> [...]
>  include/linux/netdevice.h    |    1 
>  net/d80211/ieee80211.c       |  100 +++++++++++++++++++++---------------------
>  net/d80211/ieee80211_dev.c   |   17 +++++++
>  net/d80211/ieee80211_i.h     |    9 +++-
>  net/d80211/ieee80211_iface.c |   20 ++++----
>  net/d80211/ieee80211_ioctl.c |   92 +++++++++++++++++++--------------------
>  net/d80211/ieee80211_proc.c  |    6 +--
>  net/d80211/ieee80211_scan.c  |   10 ++--
>  net/d80211/ieee80211_sta.c   |   58 ++++++++++++------------
>  net/d80211/ieee80211_sysfs.c |   26 ++++++++---
>  net/d80211/rate_control.c    |    4 +-
>  net/d80211/rate_control.h    |    4 +-
>  net/d80211/wme.c             |   26 +++++------
>  13 files changed, 206 insertions(+), 167 deletions(-)
> 
> [...]
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -371,6 +371,7 @@ #define NETIF_F_UFO             8192    
>  	void                    *ip6_ptr;       /* IPv6 specific data */
>  	void			*ec_ptr;	/* Econet specific data	*/
>  	void			*ax25_ptr;	/* AX.25 specific data */
> +	void			*ieee80211_ptr;	/* IEEE 802.11 specific data */
>  
>  /*
>   * Cache line mostly used on receive path (including eth_type_trans())
> [...]

Thanks,

-- 
Jiri Benc
SUSE Labs
