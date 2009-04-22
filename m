From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: Porting the ibm_newemac driver to use phylib (and other
 PHY/MAC questions)
Date: Wed, 22 Apr 2009 10:21:16 +0200
Message-ID: <1240388476.17445.10.camel@pasglop>
References: <f73f7ab80904171732n41832d0hc62978e57bbcc32e@mail.gmail.com>
	 <625fc13d0904200529l152b8d75g33c3f940de1b2920@mail.gmail.com>
	 <f73f7ab80904201710m57472291yf7ff86760977b8e8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	linuxppc-dev@ozlabs.org
To: Kyle Moffett <kyle@moffetthome.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37601 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751643AbZD0ALn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Apr 2009 20:11:43 -0400
In-Reply-To: <f73f7ab80904201710m57472291yf7ff86760977b8e8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-04-20 at 20:10 -0400, Kyle Moffett wrote:
> > IIRC, Ben had some issues with how phylib and the EMAC would need to
> > interact.  Not sure if he has those written down somewhere or not.
> > (CC'd).
> 
> Hmm, yeah, I'd be interested to see those.  There's enough similar
> between phylib and the EMAC and sungem drivers that I'm considering a
> series of somewhat-mechanical patches to make EMAC and sungem use the
> "struct phy_device" and "struct mii_bus" from phylib, possibly
> abstracting out some helper functions along the way.

Yup, emac and sungem predate phylib.

I had a quick look at what it would take to port at least emac over, the
main issue was that I want to be able to sleep (ie, take a mutex) in my
mdio read/write functions, and back then, phylib wouldn't let me do that
due to spinlock and timer/softirq usage.

Ben.


