From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 4/4] ipv4: mark nexthop as dead when it's subnet becomes
 unreachable
Date: Thu, 23 Jan 2014 12:06:30 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1401231158510.2682@ja.home.ssi.bg>
References: <cover.1390304505.git.popovich_sergei@mail.ru> <40044b636dbf7ae5bba5fe2873451e14438ec170.1390304505.git.popovich_sergei@mail.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Sergey Popovich <popovich_sergei@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:40688 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751468AbaAWKGv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 05:06:51 -0500
In-Reply-To: <40044b636dbf7ae5bba5fe2873451e14438ec170.1390304505.git.popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 21 Jan 2014, Sergey Popovich wrote:

> +			if (nexthop_nh->nh_dev != dev ||
> +			    nexthop_nh->nh_scope == scope ||
> +			    (ifa && !inet_ifa_match(nexthop_nh->nh_gw, ifa)))

	What if nh_gw is part from another smaller/larger subnet?
For example, what if we still have 10.0.0.200/8 ? 10.0.10.5 is
still reachable, i.e. fib_check_nh() would create such NH.
IMHO, marking NH by exact nh_gw looks more acceptable because
the exact GW becomes unreachable. Otherwise, you will need
fib_lookup() as in fib_check_nh() to check that NH becomes
unreachable.

Regards

--
Julian Anastasov <ja@ssi.bg>
