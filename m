From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: [PATCH] ieee80211: Make ieee80211_rx_any usable
Date: Tue, 18 Jul 2006 13:46:49 -0700
Message-ID: <20060718134649.0919b864.zaitcev@redhat.com>
References: <20060718203805.5E8258DEF39@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	johannes@sipsolutions.net, vda@ilport.com.ua
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:31697 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932395AbWGRUr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 16:47:58 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20060718203805.5E8258DEF39@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Jul 2006 21:38:05 +0100 (BST), Daniel Drake <dsd@gentoo.org> wrote:

> --- linux.orig/net/ieee80211/ieee80211_rx.c
> +++ linux/net/ieee80211/ieee80211_rx.c
> @@ -779,33 +779,44 @@ int ieee80211_rx(struct ieee80211_device
>  	return 0;
>  }
>  
> -/* Filter out unrelated packets, call ieee80211_rx[_mgt] */
> -int ieee80211_rx_any(struct ieee80211_device *ieee,
> +/* Filter out unrelated packets, call ieee80211_rx[_mgt]
> + * This function takes over the skb, it should not be used again after calling
> + * this function. */
> +void ieee80211_rx_any(struct ieee80211_device *ieee,
>  		     struct sk_buff *skb, struct ieee80211_rx_stats *stats)

Looks fine to me. I forgot, but I think I didn't complete switching to
ieee80211_rx_any for prism54usb. Now it may be a good time.

-- Pete
