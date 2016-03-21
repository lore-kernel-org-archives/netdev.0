From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: fix broadcast packets reception
Date: Mon, 21 Mar 2016 11:50:09 -0400 (EDT)
Message-ID: <20160321.115009.1222014596215287583.davem@davemloft.net>
References: <b2a74da9e3b01065d0244088c2038c8b6ec1d334.1458574841.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	sbohrer@rgmadvisors.com, hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756030AbcCUPuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 11:50:11 -0400
In-Reply-To: <b2a74da9e3b01065d0244088c2038c8b6ec1d334.1458574841.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Mon, 21 Mar 2016 16:42:11 +0100

> Currently, ingress ipv4 broadcast datagrams are dropped if the
> ingress interface lacks an ipv4 address. This is caused by
> multiple issues:
> 
> - in udp_v4_early_demux() ip_check_mc_rcu is invoked even on
>   bcast packets
> 
> - ip_route_input_slow() always try to validate the source
> 
> This patch tries to address both issues, invoking ip_check_mc_rcu()
> only for mcast packets and calling fib_validate_source() only
> if the in_device has an address, at least.
> 
> Fixes: 6e5403093261 ("ipv4/udp: Verify multicast group is ours in upd_v4_early_demux()")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

I'm extremely weary to change the routing lookup code wrt. broadcast, multicast,
etc. policies, ever.  The checks in there have multiple decades of precedence
and therefore are extremely dangerous to modify.

The UDP change in question didn't touch the generic routing code, therfore you
must fix this bug without modifying it either.

Sorry.
