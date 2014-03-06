From: Luca Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>
Subject: Re: [PATCH] Drivers:net:wireless:ti:wl1251: Fixed Sparse invalid
 assignment warning
Date: Thu, 06 Mar 2014 10:55:12 +0200
Message-ID: <1394096112.26326.1.camel@dubbel>
References: <1393921132-15950-1-git-send-email-surendra.tux@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, pavel-+ZI9xUNit7I@public.gmane.org, pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Surendra Patil <surendra.tux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393921132-15950-1-git-send-email-surendra.tux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-03-04 at 00:18 -0800, Surendra Patil wrote:
> Sparse warns about invalid assignment in
> drivers/net/wireless/ti/wl1251/cmd.c:451:42: warning: invalid assignment: |=
> drivers/net/wireless/ti/wl1251/cmd.c:451:42:    left side has type restricted __le16
> drivers/net/wireless/ti/wl1251/cmd.c:451:42:    right side has type int
> Hence type converted right side to __le16.
> 
> Signed-off-by: Surendra Patil <surendra.tux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/wireless/ti/wl1251/cmd.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/ti/wl1251/cmd.c b/drivers/net/wireless/ti/wl1251/cmd.c
> index 223649b..bf1fa18 100644
> --- a/drivers/net/wireless/ti/wl1251/cmd.c
> +++ b/drivers/net/wireless/ti/wl1251/cmd.c
> @@ -448,7 +448,7 @@ int wl1251_cmd_scan(struct wl1251 *wl, u8 *ssid, size_t ssid_len,
>  	 * Note: This bug may be caused by the fw's DTIM handling.
>  	 */
>  	if (is_zero_ether_addr(wl->bssid))
> -		cmd->params.scan_options |= WL1251_SCAN_OPT_PRIORITY_HIGH;
> +		cmd->params.scan_options |= cpu_to_le16(WL1251_SCAN_OPT_PRIORITY_HIGH);
>  	cmd->params.num_channels = n_channels;
>  	cmd->params.num_probe_requests = n_probes;
>  	cmd->params.tx_rate = cpu_to_le16(1 << 1); /* 2 Mbps */

AFAIR wl1251 is not really endianess-safe.  I think there are lots of
other places where endianess macros should be added.

Nothing wrong with this patch, I'm just saying that while at it, maybe
someone could take care of all the endianess issues with wl1251? ;)

--
Luca.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
