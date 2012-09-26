From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 01/11] netlink: add reference of module in
 netlink_dump_start
Date: Wed, 26 Sep 2012 09:07:27 +0200
Message-ID: <1348643247.5093.32.camel@edumazet-glaptop>
References: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org,
	linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jengelh-9+2X+4sQBs8@public.gmane.org,
	stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1348635140-20225-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-26 at 12:52 +0800, Gao feng wrote:

> +int netlink_dump_done(struct netlink_callback *cb)
> +{
> +	if (cb->module)
> +		module_put(cb->module);
> +	return 0;
> +}
> +EXPORT_SYMBOL(netlink_dump_done);
> +

No need to test cb->module being not NULL


int netlink_dump_done(struct netlink_callback *cb)
{
	module_put(cb->module);
	return 0;
}

Same remark for try_module_get() call


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
