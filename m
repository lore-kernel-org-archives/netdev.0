From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 6/7] rtlwifi: Fix smatch warnings in usb.c
Date: Sat, 14 Sep 2013 23:44:54 +0400
Message-ID: <5234BCB6.6050508@cogentembedded.com>
References: <1379094304-22041-1-git-send-email-Larry.Finger@lwfinger.net> <1379094304-22041-7-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1379094304-22041-7-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 09/13/2013 09:45 PM, Larry Finger wrote:

> Smatch displays the following:
>    CHECK   drivers/net/wireless/rtlwifi/usb.c
> drivers/net/wireless/rtlwifi/usb.c:458 _rtl_usb_rx_process_agg() warn: assigning (-98) to unsigned variable 'stats.noise'
> drivers/net/wireless/rtlwifi/usb.c:503 _rtl_usb_rx_process_noagg() warn: assigning (-98) to unsigned variable 'stats.noise'
> drivers/net/wireless/rtlwifi/usb.c:596 _rtl_rx_get_padding() info: ignoring unreachable code.
> drivers/net/wireless/rtlwifi/usb.c:596 _rtl_rx_get_padding() info: ignoring unreachable code.

> The negative number to an unsigned quantity is fixed by adding 256 to -98
> to get the equivalent negative number.

> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> ---
>   drivers/net/wireless/rtlwifi/usb.c | 10 +++++++---
>   1 file changed, 7 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
> index e56778c..9f3dcb8 100644
> --- a/drivers/net/wireless/rtlwifi/usb.c
> +++ b/drivers/net/wireless/rtlwifi/usb.c
[...]
> @@ -582,12 +582,15 @@ static void _rtl_rx_work(unsigned long param)
>   static unsigned int _rtl_rx_get_padding(struct ieee80211_hdr *hdr,
>   					unsigned int len)
>   {
> +#if NET_IP_ALIGN != 0
>   	unsigned int padding = 0;
> +#endif
>
>   	/* make function no-op when possible */
> -	if (NET_IP_ALIGN == 0 || len < sizeof(*hdr))
> +	if (NET_IP_ALIGN == 0 || len < sizeof(struct ieee80211_hdr))

    Why this collateral and undocumented change? What does it achieve?

>   		return 0;

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
