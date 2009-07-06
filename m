From: Jens Rosenboom <me@jayr.de>
Subject: Re: ipv6 preferred lifetime wraparound...
Date: Mon, 6 Jul 2009 14:27:29 +0200
Message-ID: <20090706122728.GB21357@jayr.de>
References: <1246562623.8814.21.camel@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout0.freenet.de ([195.4.92.90]:43952 "EHLO mout0.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752972AbZGFM1e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2009 08:27:34 -0400
Content-Disposition: inline
In-Reply-To: <1246562623.8814.21.camel@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

On Thu, Jul 02, 2009 at 09:23:43PM +0200, Andreas Henriksson wrote:
> Hello!
> 
> I spotted your patch[1] to prevent ipv6 preferred lifetime wraparound.
> It looks to me like you fixed the preferred lifetime, but did not touch
> the valid lifetime. According to a debian bugreport[2] it seems both of
> them like to wrap around. Shouldn't the "valid -= tval;", visible in
> your patch context, also be conditional similar to your change for
> "preferred -= tval;" ?

the first version of my patch changed the calculation for the valid
lifetime, too. However, the address is removed immediately once the
valid lifetime reaches zero. In order to see a wraparound here, the
kernel would have to be busy with other stuff for more than one second
and at the same time your userland process would need to be running to
look at this value. This seemes to me to be rather unlikely, so I
rather wanted to save some code size. But if others see a risk here,
it would certainly make sense to patch this second statement, too.

> [2]: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=518710

Btw, I failed to find a wrapped valid lifetime here, I also did some
tests myself and always saw the expired addresses being deleted well
before the timer could wrap.

Yours,
	Jens
