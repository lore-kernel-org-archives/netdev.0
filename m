From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Tue, 11 Mar 2014 16:20:29 +0100
Message-ID: <20140311152029.GB29404@order.stressinduktion.org>
References: <20140310.010313.703650662340510015.davem@davemloft.net> <20140310081533.GA27052@unicorn.suse.cz> <20140310120016.GH5493@order.stressinduktion.org> <20140310.223841.953940361609160158.davem@davemloft.net> <20140311095309.GA3287@unicorn.suse.cz> <20140311150814.GB3287@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56731 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbaCKPUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 11:20:31 -0400
Content-Disposition: inline
In-Reply-To: <20140311150814.GB3287@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2014 at 04:08:14PM +0100, Michal Kubecek wrote:
> +static int fib6_commit_metrics(struct dst_entry *old_dst, struct dst_entry *dst,
> +			       struct nlattr *mx, int mx_len)
> +{
> +	struct nlattr *nla;
> +	int remaining;
> +	u32 *mp;
> +
> +	/* no new metrics and not inheriting an inetpeer with old ones */
> +	if (!mx && (!(dst->flags & DST_HOST) || !old_dst ||
> +		    dst_metrics_read_only(old_dst)))
> +		return 0;
> +
> +	mp = dst_metrics_write_ptr(dst);
> +	if ((dst->flags & DST_HOST) &&
> +	    old_dst && !dst_metrics_read_only(old_dst))
> +		memset(mp, 0, RTAX_MAX * sizeof(u32));
> +

Small question:

Wouldn't make it easier if we move the kzalloc/dst_init_metrics part to
here in case we aren't a DST_HOST and remove it from ip6_route_add, too?

Otherwise (but really just a first look!), it seems ok to me.

Thanks,

  Hannes
