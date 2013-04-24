From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] ipv6: separate out procfs code from mcast.c
Date: Wed, 24 Apr 2013 11:33:39 +0800
Message-ID: <1366774419.3849.8.camel@cr0>
References: <1366701302.21136.19.camel@cr0>
	 <20130423.031805.544535198246859192.davem@davemloft.net>
	 <1366702220.21136.23.camel@cr0>
	 <20130423.033620.1101068519499870853.davem@davemloft.net>
	 <1366702893.21136.28.camel@cr0> <87d2tlv32i.fsf@nemi.mork.no>
	 <1366733588.4016.29.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757678Ab3DXDdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 23:33:54 -0400
In-Reply-To: <1366733588.4016.29.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 17:13 +0100, Ben Hutchings wrote:
> 
> A more type-safe approach would be to define something like:
> 
> /* net/ipv6.h */
> struct ipv6_mcast_ops {
> 	...
> };
> extern const struct ipv6_mcast_ops *ipv6_mcast_ops;
> 
> /* net/ipv6/addrconf_core.c */
> const struct ipv6_mcast_ops *ipv6_mcast_ops;
> EXPORT_SYMBOL_GPL(ipv6_mcast_ops);
> 
> /* net/ipv6/af_inet6.c */
> static const struct ipv6_mcast_ops ipv6_mcast_ops_impl = {
> 	...
> };
> static int __init inet6_init(void)
> {
> 	...
> 	ipv6_mcast_ops = &ipv6_mcast_ops_impl;
> 	return 0;
> 	...
> }
> static void __exit inet6_exit(void)
> {
> 	...
> 	ipv6_mcast_ops = NULL;
> 	...
> }

Yeah! That's a nice stub! I think this is the only doable and acceptable
solution so far.

Thanks a lot!
