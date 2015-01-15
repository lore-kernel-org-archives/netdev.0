From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH for 3.19 2/3] rtlwifi: Fix handling of new style descriptors
Date: Thu, 15 Jan 2015 13:44:51 +0200
Message-ID: <877fwoxo7g.fsf@kamboji.qca.qualcomm.com>
References: <1421257036-5382-1-git-send-email-Larry.Finger@lwfinger.net>
	<1421257036-5382-3-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421257036-5382-3-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
	(Larry Finger's message of "Wed, 14 Jan 2015 11:37:15 -0600")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> writes:

> From: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
>
> The hardware and firmware for the RTL8192EE utilize a FIFO list of
> descriptors. There were some problems with the initial implementation.
> The worst of these failed to detect that the FIFO was becoming full,
> which led to the device needing to be power cycled. As this condition
> is not relevant to most of the devices supported by rtlwifi, a callback
> routine was added to detect this situation. This patch implements the
> necessary changes in the pci handler.
>
> Signed-off-by: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>

[...]

> --- a/drivers/net/wireless/rtlwifi/wifi.h
> +++ b/drivers/net/wireless/rtlwifi/wifi.h
> @@ -2172,6 +2172,7 @@ struct rtl_hal_ops {
>  	void (*add_wowlan_pattern)(struct ieee80211_hw *hw,
>  				   struct rtl_wow_pattern *rtl_pattern,
>  				   u8 index);
> +	u16 (*get_available_desc)(struct ieee80211_hw *hw, u8 q_idx);

I don't see this op set anywhere within the patch. Is that correct or
did I miss something?

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
