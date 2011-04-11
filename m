From: Daniel Walter <dwalter@barracuda.com>
Subject: Re: ipv6: Add support for RTA_PREFSRC
Date: Mon, 11 Apr 2011 09:22:32 +0200
Message-ID: <1302506552.8923.21.camel@localhost>
References: <20110401.204613.246536923.davem@davemloft.net>
	 <1301903804.31789.234.camel@localhost>
	 <20110406.183716.226766155.davem@davemloft.net>
	 <20110407212552.GA11115@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bn-scl-osf02.barracuda.com ([64.235.144.26]:52348 "EHLO
	bn-scl-osf02.barracuda.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753050Ab1DKHWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 03:22:44 -0400
In-Reply-To: <20110407212552.GA11115@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-07 at 14:25 -0700, Florian Westphal wrote:
> David Miller <davem@davemloft.net> wrote:
> > From: Daniel Walter <dwalter@barracuda.com>
> > Date: Mon, 4 Apr 2011 09:56:44 +0200
> > > This reduces the RTA_PREFSRC support to netlink only, unless
> > > we break the struct.
> > 
> [..]
> > Since you do the prefsrc extraction in at least two places, make a
> > helper function that does the whole "if prefsrc.plen use prefsrc, else
> > use ipv6_dev_get_saddr()"
> > 
> > This would be akin to ipv4's FIB_RES_PREFSRC
> 
> OK, I'll bite.
> 
> Whats wrong with using ipv6 addrlabels to pick the desired address,
> and, if there is a problem, why is it not fixable?
> 
> Just wondering...
Hi,

As far as I've understood addrlabels, they allow me to define the
overall preferred source. As soon I want to select the default src
only for a given route, addrlabels cannot do the job.
for example:
ip-addresses on eth0
2001:0DB8::1/64
2001:0DB8::2/64
routes
2001:0DB8::/64
2001:0DB8:0:dead::/64 via 2001:0DB8::1234/64

addrlabel allow me to set the default source address to 2001:0DB8::1 for
both routes. with pref_src selection one is able to set the default
outgoing address for each route to the needed address, which may be
2001:0DB8::1 for the first route, and 2001:0DB8::2 for the remaining.

Please feel free to correct me if I misunderstood something.

--


Barracuda Networks solutions are now available as virtual appliances. 
Visit www.barracudanetworks.com/vx for more information.



