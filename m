From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 1/1] rtlwifi: Convert drivers to use new API for
 ieee80211_is_robust_mgmt_frame()
Date: Fri, 21 Feb 2014 15:38:50 +0100
Message-ID: <1392993530.4346.49.camel@jlt4.sipsolutions.net>
References: <1392993211-3848-1-git-send-email-Larry.Finger@lwfinger.net>
	 (sfid-20140221_153342_109062_89D3C0C6)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1392993211-3848-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> (sfid-20140221_153342_109062_89D3C0C6)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-02-21 at 08:33 -0600, Larry Finger wrote:
> Drivers rtl8188ee, rtl8192ce, rtl8192se, and rtl8723ae all use this routine.
> In addition, all callers of ieee80211_is_robust_mgmt_frame() have access to the
> skb. Thus, it is trivial to use the new API rather than the underscored old version.

Unfortunately, I'm pretty sure this is incorrect. I looked at this code
before, and take for example:

> +++ b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
> @@ -334,8 +334,8 @@ bool rtl8723ae_rx_query_desc(struct ieee80211_hw *hw,
>  			/* during testing, hdr could be NULL here */
>  			return false;
>  		}
> -		if ((_ieee80211_is_robust_mgmt_frame(hdr)) &&
> -			(ieee80211_has_protected(hdr->frame_control)))
> +		if ((ieee80211_is_robust_mgmt_frame(skb)) &&
> +		    (ieee80211_has_protected(hdr->frame_control)))

Here, hdr is set like this:

                hdr = (struct ieee80211_hdr *)(skb->data +
                       status->rx_drvinfo_size + status->rx_bufshift);  

so the skb clearly contains something else before the hdr, and the
conversion is probably not right because it assumes hdr == skb->data,
where here it isn't that but instead (skb->data + something).

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
