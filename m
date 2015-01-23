From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 5/6] rtlwifi: btcoexist: Add routines for RTL8812AE - all configs
Date: Fri, 23 Jan 2015 22:12:30 +0200
Message-ID: <87mw59jlxt.fsf@kamboji.qca.qualcomm.com>
References: <1422033044-7461-1-git-send-email-Larry.Finger@lwfinger.net>
	<1422033044-7461-6-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422033044-7461-6-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
	(Larry Finger's message of "Fri, 23 Jan 2015 11:10:43 -0600")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> writes:

> From: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
>
> This patch adds the routines used for all antenna configurations.
>
> Signed-off-by: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>

The commit log is REALLY vague...

> +static u8 rtl_btcoex_create_kernel_socket(struct rtl_priv *rtlpriv,
> +					  u8 is_invite)
> +{
> +	struct bt_coex_info *pcoex_info = &rtlpriv->coex_info;
> +	s8 kernel_socket_err;
> +
> +	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
> +		  "%s CONNECT_PORT %d\n", __func__, CONNECT_PORT);
> +
> +	if (!pcoex_info) {
> +		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL, "coex_info: NULL\n");
> +		return _FAIL;
> +	}
> +
> +	kernel_socket_err = sock_create(PF_INET, SOCK_DGRAM, 0,
> +					&pcoex_info->udpsock);
> +	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
> +		  "binding socket, err = %d\n", kernel_socket_err);
> +
> +	if (kernel_socket_err < 0) {
> +		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
> +			  "Error during creation of socket error:%d\n",
> +			  kernel_socket_err);
> +		return _FAIL;
> +	}
> +	memset(&pcoex_info->sin, 0, sizeof(pcoex_info->sin));
> +	pcoex_info->sin.sin_family = AF_INET;
> +	pcoex_info->sin.sin_port = htons(CONNECT_PORT);
> +	pcoex_info->sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);

...and then I see stuff like this. What an earth does this do?

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
