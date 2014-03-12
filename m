From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Wed, 12 Mar 2014 16:54:43 -0400 (EDT)
Message-ID: <20140312.165443.1358759725438654072.davem@davemloft.net>
References: <20140310.223841.953940361609160158.davem@davemloft.net>
	<20140311095309.GA3287@unicorn.suse.cz>
	<20140311150814.GB3287@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41726 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692AbaCLUyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 16:54:44 -0400
In-Reply-To: <20140311150814.GB3287@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Tue, 11 Mar 2014 16:08:14 +0100

> +	nla_for_each_attr(nla, mx, mx_len, remaining) {
> +		int type = nla_type(nla);
> +
> +		if (type) {
> +			if (type > RTAX_MAX)
> +				return -EINVAL;
> +
> +			mp[type - 1] = nla_get_u32(nla);
> +		}
> +	}

It was surprising to me that nla_for_each_attr() works with a second
argument of NULL.

It only does so when the length is zero, due to how the test in nla_ok()
is codified.

I know it's a minor nit, but can you only execute this loop if mx is
non-NULL?

Perhaps you can put this into (yet another) helper function:

int __fib6_commit_metrics(u32 *mp, struct nlattr *mx, int mx_len)

Otherwise looks good to me.
