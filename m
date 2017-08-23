From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH v2] at76c50x-usb: check memory allocation failure
Date: Wed, 23 Aug 2017 17:49:15 +0300
Message-ID: <87tw0ywd90.fsf@kamboji.qca.qualcomm.com>
References: <1503498556-13835-1-git-send-email-himanshujha199640@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Himanshu Jha <himanshujha199640-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1503498556-13835-1-git-send-email-himanshujha199640-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
        (Himanshu Jha's message of "Wed, 23 Aug 2017 19:59:16 +0530")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Himanshu Jha <himanshujha199640-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Check memory allocation failure and return -ENOMEM rather than just
> retuning void.
>
> Signed-off-by: Himanshu Jha <himanshujha199640-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

[...]

> -static void at76_dump_mib_mac_addr(struct at76_priv *priv)
> +static int at76_dump_mib_mac_addr(struct at76_priv *priv)
>  {
>  	int i;
>  	int ret;
> @@ -940,7 +940,7 @@ static void at76_dump_mib_mac_addr(struct at76_priv *priv)
>  					 GFP_KERNEL);
>  
>  	if (!m)
> -		return;
> +		return -ENOMEM;

This feels rather pointless. You are changing these functions to return
an error code but the callers it anyway. And besides, did you check
where these are actually used?

	if (at76_debug & DBG_MIB) {
		at76_dump_mib_mac(priv);
		at76_dump_mib_mac_addr(priv);
		at76_dump_mib_mac_mgmt(priv);
		at76_dump_mib_mac_wep(priv);
		at76_dump_mib_mdomain(priv);
		at76_dump_mib_phy(priv);
		at76_dump_mib_local(priv);
	}

So it's just for debug messages and the current error handling looks the
correct approach. There is not much anything else we can do than just
skip the message printout.

-- 
Kalle Valo
