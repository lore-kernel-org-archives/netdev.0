From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH 1/5] netlink: extended ACK reporting
Date: Sat, 8 Apr 2017 14:36:39 -0400
Message-ID: <14c58480-cd03-4d61-fffa-fab6e437a7ea@cumulusnetworks.com>
References: <20170408174900.12820-1-johannes@sipsolutions.net>
 <20170408174900.12820-2-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170408174900.12820-2-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/8/17 1:48 PM, Johannes Berg wrote:
> diff --git a/include/linux/netlink.h b/include/linux/netlink.h
> index da14ab61f363..47562e940e9c 100644
> --- a/include/linux/netlink.h
> +++ b/include/linux/netlink.h
> @@ -62,11 +62,41 @@ netlink_kernel_create(struct net *net, int unit, struct netlink_kernel_cfg *cfg)
>  	return __netlink_kernel_create(net, unit, THIS_MODULE, cfg);
>  }
>  
> +/**
> + * struct netlink_ext_ack - netlink extended ACK report struct
> + * @_msg: message string to report - don't access directly, use
> + *	%NL_SET_ERR_MSG
> + * @bad_attr: attribute with error
> + * @missing_attr: number of missing attr (or 0)
> + * @cookie: cookie data to return to userspace (for success)
> + * @cookie_len: actual cookie data length
> + */
> +struct netlink_ext_ack {
> +	const char *_msg;
> +	const struct nlattr *bad_attr;
> +	u16 missing_attr;
> +	u8 cookie[NETLINK_MAX_COOKIE_LEN];
> +	u8 cookie_len;
> +};
> +

I think v3 is in your future ...

/home/dsa/kernel-4.git/include/linux/netlink.h:78:12: error:
‘NETLINK_MAX_COOKIE_LEN’ undeclared here (not in a function)
  u8 cookie[NETLINK_MAX_COOKIE_LEN];
            ^

it's defined in patch 3; needed in patch 1
