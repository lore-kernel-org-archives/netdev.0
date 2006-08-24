From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [RFC] make d80211 use nl80211
Date: Thu, 24 Aug 2006 16:05:04 +0200
Message-ID: <20060824160504.54b81641@griffin.suse.cz>
References: <1156254813.3825.2.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:736 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751544AbWHXOFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 10:05:06 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1156254813.3825.2.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Aug 2006 15:53:33 +0200, Johannes Berg wrote:
> This patch makes d80211 partially configurable using the
> infrastructure that nl80211 provides. So far, it allows
> packet injection and adding/removing virtual interfaces.

Just minor things:

> [...]
> --- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-22 15:47:46.000000000 +0200
> +++ wireless-dev/net/d80211/ieee80211.c	2006-08-22 15:47:48.000000000 +0200
> [...]
> @@ -4323,6 +4363,7 @@ struct net_device *ieee80211_alloc_hw(si
>  	priv_size = ((sizeof(struct ieee80211_sub_if_data) +
>  		      NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST) +
>  		    priv_data_len;
> +
>  	mdev = alloc_netdev(priv_size, "wmaster%d", ether_setup);
>  	if (!mdev) {
>  		ieee80211_dev_free(local);

Remove this hunk, please.

> [...]
> +static int d80211_interfaces(void *priv, void *data,
> +			     int (*one)(void *data, int ifindex))

Please use ieee80211_ prefix, not d80211_.

> [...]
> +static int d80211_inject(void *priv, void *frame, int framelen, u32 flags,
> +			 int queue)
> +{
> +	struct ieee80211_local *local = priv;
> +	struct ieee80211_tx_packet_data *pkt_data;
> +	struct sk_buff *pkt;
> +	void *pktdata;
> +
> +	pkt = alloc_skb(framelen, GFP_KERNEL);
> +	pktdata = skb_put(pkt, framelen);
> +	memcpy(pktdata, frame, framelen);
> +
> +	pkt_data = (struct ieee80211_tx_packet_data *) pkt->cb;
> +	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));

This is not necessary, cb is zeroed in alloc_skb.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
