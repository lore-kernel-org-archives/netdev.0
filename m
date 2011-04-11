From: Florian Westphal <fw@strlen.de>
Subject: Re: ipv6: Add support for RTA_PREFSRC
Date: Mon, 11 Apr 2011 09:58:25 +0200
Message-ID: <20110411075825.GA21943@Chamillionaire.breakpoint.cc>
References: <20110401.204613.246536923.davem@davemloft.net>
 <1301903804.31789.234.camel@localhost>
 <20110406.183716.226766155.davem@davemloft.net>
 <20110407212552.GA11115@Chamillionaire.breakpoint.cc>
 <1302506552.8923.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Walter <dwalter@barracuda.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:55344 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753394Ab1DKH63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 03:58:29 -0400
Content-Disposition: inline
In-Reply-To: <1302506552.8923.21.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Walter <dwalter@barracuda.com> wrote:
> On Thu, 2011-04-07 at 14:25 -0700, Florian Westphal wrote:
> > David Miller <davem@davemloft.net> wrote:
> > > This would be akin to ipv4's FIB_RES_PREFSRC
> > 
> > OK, I'll bite.
> > 
> > Whats wrong with using ipv6 addrlabels to pick the desired address,
> > and, if there is a problem, why is it not fixable?
> > 
> > Just wondering...
> Hi,
> 
> As far as I've understood addrlabels, they allow me to define the
> overall preferred source. As soon I want to select the default src
> only for a given route, addrlabels cannot do the job.
> for example:
> ip-addresses on eth0
> 2001:0DB8::1/64
> 2001:0DB8::2/64
> routes
> 2001:0DB8::/64
> 2001:0DB8:0:dead::/64 via 2001:0DB8::1234/64
> 
> addrlabel allow me to set the default source address to 2001:0DB8::1 for
> both routes. with pref_src selection one is able to set the default
> outgoing address for each route to the needed address, which may be
> 2001:0DB8::1 for the first route, and 2001:0DB8::2 for the remaining.
> 
> Please feel free to correct me if I misunderstood something.

ip addrlabel add label 1000 prefix 2001:db8::1
ip addrlabel add label 1000 prefix 2001:db8::/64
ip addrlabel add label 1001 prefix 2001:db8::2
ip addrlabel add label 1001 prefix 2001:0DB8:0:dead::/64

ip route add 2001:db8:0:dead::/64 via 2001:db8::1234

This should tell the stack to pick 2001:db8::1 as the
source address when talking to 2001:db8::/64, and to
use 2001:db8::2 when talking to 2001:0DB8:0:dead::42.
