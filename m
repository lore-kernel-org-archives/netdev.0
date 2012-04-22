From: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
Subject: Re: [PATCH] wl12xx: fix size of two memset's in
 wl1271_cmd_build_arp_rsp()
Date: Sun, 22 Apr 2012 22:57:09 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1204222255460.27455@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1204222252000.27455@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.00.1204222252000.27455-h2p7t3/P30RzeRGmFJ5qR7ZzlVVXadcDXqFh9Ls21Oc@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 22 Apr 2012, Jesper Juhl wrote:

> We currently do this:
> 
> int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
> ...
> 	struct wl12xx_arp_rsp_template *tmpl;
> 	struct ieee80211_hdr_3addr *hdr;
> ...
> 	tmpl = (struct wl12xx_arp_rsp_template *)skb_put(skb, sizeof(*tmpl));
> 	memset(tmpl, 0, sizeof(tmpl));
> ...
> 	hdr = (struct ieee80211_hdr_3addr *)skb_push(skb, sizeof(*hdr));
> 	memset(hdr, 0, sizeof(*hdr));
> ...
> 
> I believe we want to set the entire structures to 0 with those
> memset() calls, not just zero the initial part of them (size of the
> pointer bytes).
> 

Sorry, I accidentally copied that code from the fixed version. The above 
should read:


We currently do this:

int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
...
      struct wl12xx_arp_rsp_template *tmpl;
      struct ieee80211_hdr_3addr *hdr;
...
      tmpl = (struct wl12xx_arp_rsp_template *)skb_put(skb, sizeof(*tmpl));
      memset(tmpl, 0, sizeof(tmpl));
...
      hdr = (struct ieee80211_hdr_3addr *)skb_push(skb, sizeof(*hdr));
      memset(hdr, 0, sizeof(hdr));
...

I believe we want to set the entire structures to 0 with those
memset() calls, not just zero the initial part of them (size of the
pointer bytes).





> Signed-off-by: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
> ---
>  drivers/net/wireless/wl12xx/cmd.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/wl12xx/cmd.c b/drivers/net/wireless/wl12xx/cmd.c
> index 3414fc1..8e65529 100644
> --- a/drivers/net/wireless/wl12xx/cmd.c
> +++ b/drivers/net/wireless/wl12xx/cmd.c
> @@ -1249,7 +1249,7 @@ int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
>  	skb_reserve(skb, sizeof(*hdr) + WL1271_EXTRA_SPACE_MAX);
>  
>  	tmpl = (struct wl12xx_arp_rsp_template *)skb_put(skb, sizeof(*tmpl));
> -	memset(tmpl, 0, sizeof(tmpl));
> +	memset(tmpl, 0, sizeof(*tmpl));
>  
>  	/* llc layer */
>  	memcpy(tmpl->llc_hdr, rfc1042_header, sizeof(rfc1042_header));
> @@ -1298,7 +1298,7 @@ int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
>  
>  	/* mac80211 header */
>  	hdr = (struct ieee80211_hdr_3addr *)skb_push(skb, sizeof(*hdr));
> -	memset(hdr, 0, sizeof(hdr));
> +	memset(hdr, 0, sizeof(*hdr));
>  	fc = IEEE80211_FTYPE_DATA | IEEE80211_FCTL_TODS;
>  	if (wlvif->sta.qos)
>  		fc |= IEEE80211_STYPE_QOS_DATA;
> 

-- 
Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
