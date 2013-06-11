From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/5] netfilter: xt_TCPMSS: Fix violation of RFC879 in
 absence of MSS option
Date: Tue, 11 Jun 2013 18:25:25 +0200
Message-ID: <20130611162525.GA11547@localhost>
References: <1370880461-4265-1-git-send-email-pablo@netfilter.org>
 <1370880461-4265-4-git-send-email-pablo@netfilter.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7282@saturn3.aculab.com>
 <20130610071954.GA13500@gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7285@saturn3.aculab.com>
 <20130610082739.GA14277@gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7286@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Oester <kernel@linuxace.com>, netfilter-devel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40733 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754199Ab3FKQZc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jun 2013 12:25:32 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7286@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 11, 2013 at 05:09:11PM +0100, David Laight wrote:
> > On Tue, Jun 11, 2013 at 04:00:06PM +0100, David Laight wrote:
> > > To quote that bug:
> > >
> > > I stumbled upon this problem in debian bug #541658[1] ("[iceweasel] cannot open
> > > research.microsoft.com" - only worth reading for entertainment purposes) and,
> > > after that bug was closed, analysed it in my blog[2] until a friend of mine
> > > found out why the page loads when clamping mss to pmtu is disabled or
> > > restricted to a range (like with "iptables -A FORWARD -p tcp --tcp-flags
> > > SYN,RST SYN -m tcpmss --mss 1400:1536 -j TCPMSS --clamp-mss-to-pmtu") but
> > > doesn't load with "simple" clamping. His really great and detailed analysation
> > > of the problem may be seen at [3].
> > >
> > > If I read/understand that correctly, clamping to 1400 worked - there was
> > > no need to clamp all the way down to 536.
> > 
> > You are not understanding the issue correctly.  The reason the command worked with
> > "-m tcpmss --mss 1400:1536" is because that implies an MSS option was provided.
> > The issue occurs only when NO MSS option is sent.  In these cases, we cannot
> > ASSUME that it is ok to use some arbitrarily high value (1400 as you propose).
> > The RFC is clear on this point.
> 
> My problem is that I don't want TCP connections to drop the mss to
> 536 when talking to minimal/old implementations that don't add any
> options to SYN packets.

That will not happen if you use:

... -m tcpmss --mss 1400:1536 ...

as in your example above.
