From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] ipv4: fix broadcast packets reception
Date: Mon, 21 Mar 2016 17:12:40 +0100
Message-ID: <1458576760.4542.45.camel@redhat.com>
References: <b2a74da9e3b01065d0244088c2038c8b6ec1d334.1458574841.git.pabeni@redhat.com>
	 <20160321.115009.1222014596215287583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	sbohrer@rgmadvisors.com, hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59208 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756670AbcCUQMp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2016 12:12:45 -0400
In-Reply-To: <20160321.115009.1222014596215287583.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-21 at 11:50 -0400, David Miller wrote:
> From: Paolo Abeni <pabeni@redhat.com>
> Date: Mon, 21 Mar 2016 16:42:11 +0100
> 
> > Currently, ingress ipv4 broadcast datagrams are dropped if the
> > ingress interface lacks an ipv4 address. This is caused by
> > multiple issues:
> > 
> > - in udp_v4_early_demux() ip_check_mc_rcu is invoked even on
> >   bcast packets
> > 
> > - ip_route_input_slow() always try to validate the source
> > 
> > This patch tries to address both issues, invoking ip_check_mc_rcu()
> > only for mcast packets and calling fib_validate_source() only
> > if the in_device has an address, at least.
> > 
> > Fixes: 6e5403093261 ("ipv4/udp: Verify multicast group is ours in upd_v4_early_demux()")
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> 
> I'm extremely weary to change the routing lookup code wrt. broadcast, multicast,
> etc. policies, ever.  The checks in there have multiple decades of precedence
> and therefore are extremely dangerous to modify.
> 
> The UDP change in question didn't touch the generic routing code, therfore you
> must fix this bug without modifying it either.

ok, I'll try to find something less intrusive. I'm not sure if it will
be possible.

Just a little addendum: the current issue is not caused only by the
commit 6e5403093261, but also by some less trivial/older change into the
routing lookup code I was unable to track exactly.

Cheers,

Paolo 
