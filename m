From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [RFC] mac80211: clean up frame receive handling
Date: Thu, 13 Dec 2007 15:49:33 -0500
Message-ID: <20071213204933.GD3083@tuxdriver.com>
References: <1197483844.6558.158.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jouni Malinen <j@w1.fi>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1197483844.6558.158.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 12, 2007 at 07:24:04PM +0100, Johannes Berg wrote:

> @@ -1014,6 +992,24 @@ ieee80211_drop_unencrypted(struct ieee80
>  	return 0;
>  }
>  
> +static bool ieee80211_frame_allowed(struct ieee80211_txrx_data *rx)
> +{
> +	static const u8 pae_group_addr[ETH_ALEN]
> +		= { 0x01, 0x80, 0xC2, 0x00, 0x00, 0x03 };
> +	struct ethhdr *ehdr = (struct ethhdr *)rx->skb->data;
> +
> +	if (rx->skb->protocol == htons(ETH_P_PAE) &&
> +	    (compare_ether_addr(ehdr->h_dest, pae_group_addr) == 0 ||
> +	     compare_ether_addr(ehdr->h_dest, rx->dev->dev_addr) == 0))
> +		return true;

Should you reverse these two compare_ether_addr calls?
rx->dev->dev_addr seems more likely for any given packet.  It probably
makes little difference but it seems like checking for that first
would still be better.

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
