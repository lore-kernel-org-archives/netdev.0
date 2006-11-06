From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFC: 2.6 patch] hostap_80211_rx(): fix a use-after-free
Date: Mon, 6 Nov 2006 21:46:51 +0300
Message-ID: <20061106184651.GA4972@martell.zuzino.mipt.ru>
References: <20061106142148.GO5778@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752033AbWKFSrF@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20061106142148.GO5778@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 06, 2006 at 03:21:48PM +0100, Adrian Bunk wrote:
> This patch fixes a use-after-free for "skb" spotted by the Coverity
> checker.

> --- linux-2.6/drivers/net/wireless/hostap/hostap_80211_rx.c.old
> +++ linux-2.6/drivers/net/wireless/hostap/hostap_80211_rx.c
> @@ -1004,10 +1004,10 @@ void hostap_80211_rx(struct net_device *
>  			if (local->hostapd && local->apdev) {
>  				/* Send IEEE 802.1X frames to the user
>  				 * space daemon for processing */
> -				prism2_rx_80211(local->apdev, skb, rx_stats,
> -						PRISM2_RX_MGMT);
>  				local->apdevstats.rx_packets++;
>  				local->apdevstats.rx_bytes += skb->len;
> +				prism2_rx_80211(local->apdev, skb, rx_stats,
> +						PRISM2_RX_MGMT);
>  				goto rx_exit;

Network drivers set rx_packets and rx_bytes after netif_rx. And last_rx,
too. The trick seems to be to use pkt_len variable.
