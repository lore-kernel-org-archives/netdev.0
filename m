From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v7 2/2] mac80211: multicast to unicast conversion
Date: Mon, 21 Nov 2016 14:24:43 +0100
Message-ID: <1479734683.8662.27.camel@sipsolutions.net>
References: <1477921260-24556-1-git-send-email-michael-dev@fami-braun.de>
         <1477921260-24556-2-git-send-email-michael-dev@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        projekt-wlan-3kN+8DYepx7zMJDuovMtMLNAH6kLmebB@public.gmane.org
To: Michael Braun <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477921260-24556-2-git-send-email-michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-10-31 at 14:41 +0100, Michael Braun wrote:
 
> +static int ieee80211_set_multicast_to_unicast(struct wiphy *wiphy,
> +					      struct net_device
> *dev,
> +					      const bool enabled)
> +{
> +	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
> +
> +	/* not supported with P2P_GO for now */
> +	if (sdata->vif.type != NL80211_IFTYPE_AP)
> +		return -EOPNOTSUPP;

This check is completely inefficient, since vif.type is == AP for GO.

Also, I see no reason to restrict it that way, why not remove the
check? There's no difference.

> +static inline int
> +ieee80211_multicast_to_unicast(struct sk_buff *skb, struct
> net_device *dev)

use bool return?

johannes
