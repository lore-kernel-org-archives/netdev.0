From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH v2 0/4] net: Revive fixed link support
Date: Sat, 18 Jul 2009 22:04:48 +0400
Message-ID: <20090718180448.GA3252@oksana.dev.rtsoft.ru>
References: <20090717065220.15652.93331.stgit@localhost.localdomain>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, afleming@freescale.com,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	leoli@freescale.com
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:23709 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751482AbZGRSEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2009 14:04:50 -0400
Content-Disposition: inline
In-Reply-To: <20090717065220.15652.93331.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2009 at 01:31:25AM -0600, Grant Likely wrote:
[...]
> Part of the problem I think is that the phylib code merges two separate
> constructs; the construct of an MDIO bus (on which many device may
> reside, not all of them PHYs), and the construct of an MII link whose
> speed and configuration need to be manipulated.  I've run into problems
> myself on how best to handle things like Ethernet switches which
> definitely do not behave like PHYs and the phylib state machine cannot
> be used on them.  It seems to me that the whole 'dummy phy' approach
> is just an artifact of the phylib model not being quite right yet.

Yep. With a bit of phylib rework we can remove all the MDIO emulation
stuff from phy/fixed.c driver, and leave there just speed/duplex/pause
assignments.

Though, I still believe that we should avoid two code paths in the
drivers. One of the code paths will be constantly broken if we do so.

> I
> want to investigate the possibility of separating the two concepts, but
> that will require a fair bit of thought and experimentation.

That would be great indeed.

[...]
> Anton, once again I don't have hardware to test this, so I rely on you
> to tell be if I screwed it up.  It has been compile tested.

Works fine here, thanks!

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
