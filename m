From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 2/2] ieee802154: add virtual loopback driver
Date: Mon, 10 Aug 2009 19:28:55 +0200
Message-ID: <4A8058D7.7070106@hartkopp.net>
References: <1249913800-10176-1-git-send-email-dbaryshkov@gmail.com> <1249913800-10176-2-git-send-email-dbaryshkov@gmail.com> <1249913800-10176-3-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1249913800-10176-3-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dmitry Eremin-Solenikov wrote:
> fakelb is a virtual loopback driver implementing one or several
> interconnected radios. 

> +
> +static int radios = 3;
> +module_param(radios, int, 0444);
> +MODULE_PARM_DESC(radios, "Number of simulated radios");
> +


> +
> +	for (i = 0; i < radios; i++) {
> +		err = ieee802154fake_add_priv(&pdev->dev, priv);
> +		if (err < 0)
> +			goto err_slave;
> +	}
> +

Hi Dimtry,

creating software networking devices like this is IMO not state-of-the-art for
 kernel inclusion.

Please use the NETLINK interface for creating the virtual loopback drivers,
like e.g. the virtual CAN driver (drivers/net/can/vcan.c) does.

Regards,
Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
