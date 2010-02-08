From: Daniel Mack <daniel@caiaq.de>
Subject: Re: smsc911x suspend/resume
Date: Mon, 8 Feb 2010 12:53:16 +0100
Message-ID: <20100208115316.GA28972@buzzloop.caiaq.de>
References: <4B6FF5E2.6060304@compulab.co.il>
 <OFE2B2FE18.A8D1D506-ON802576C4.003FCA39-802576C4.0040B683@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Rapoport <mike@compulab.co.il>,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	netdev@vger.kernel.org, Ian.Saturley@smsc.com,
	Vlad.Lyalikov@smsc.com, davem@davemloft.net
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:56920 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988Ab0BHLxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 06:53:23 -0500
Content-Disposition: inline
In-Reply-To: <OFE2B2FE18.A8D1D506-ON802576C4.003FCA39-802576C4.0040B683@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 08, 2010 at 11:46:39AM +0000, Steve.Glendinning@smsc.com wrote:
> > Anyway, I have all the supplies except VDDVARIO shut down...
> > And the datasheet is indeed comprehensively describes chip power states
> > but I haven't found there anything about supplies required to stay on
> > during suspend...
> 
> I don't have the code in front of me (I'm travelling today) but IIRC
> the driver doesn't place the LAN9220 in a specific power saving state,
> so as far as the LAN9220 is concerned it's not actually suspended.

It does, I added that awhile back in b6907b0c7. But as I say, this is
currently hard-coded to D1, and if support for D2 is desired, we would
need to make that a platform data option.

> It's hard to do this in a "generic" way: some people expect their link
> to stay up during suspend, some want suspend to completely power down
> the ethernet chip, and some want to use one of several WoL modes. 
> 
> David: What's the "done thing" here for similar non-pci drivers?
> Obviously "doesn't work after suspend" isn't the intended behaviour, so
> there's definitely room for improvement!
> 
> > > Also have a look at the Raumfeld device patches which use exactly this
> > > chip and which can suspend and resume just fine. You'll need to check
> > > out Eric's devel branch for that.
> 
> Daniel: I haven't seen this, do you have a location for the git tree?

git://git.kernel.org/pub/scm/linux/kernel/git/ycmiao/pxa-linux-2.6.git

See the 'devel' branch. But there's actually nothing exciting in there,
it's just a simple platform support.

Daniel
