From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Wed, 18 May 2016 16:21:37 +0930
Message-ID: <20160518065137.GJ27564@marvin.atrad.com.au>
References: <20151120024616.GL7136@marvin.atrad.com.au>
 <20151120224534.GA25025@electric-eye.fr.zoreil.com>
 <20151121223627.GA3493@electric-eye.fr.zoreil.com>
 <20151122225039.GE2957@marvin.atrad.com.au>
 <20151122230244.GA12249@electric-eye.fr.zoreil.com>
 <20151130064255.GL5537@marvin.atrad.com.au>
 <20151201235852.GA16429@electric-eye.fr.zoreil.com>
 <20160208023318.GJ9174@marvin.atrad.com.au>
 <20160407024417.GE17921@marvin.atrad.com.au>
 <20160517065231.GO30050@marvin.atrad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.atrad.com.au ([150.101.241.2]:35975 "EHLO
	server.atrad.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbcERGvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 02:51:46 -0400
Content-Disposition: inline
In-Reply-To: <20160517065231.GO30050@marvin.atrad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 07, 2016 at 12:14:18PM +0930, Jonathan Woithe wrote:
> On Mon, Feb 08, 2016 at 01:03:19PM +1030, Jonathan Woithe wrote:
> > On Wed, Dec 02, 2015 at 12:58:52AM +0100, Francois Romieu wrote:
> > > Jonathan Woithe <jwoithe@atrad.com.au> :
> > > [...]
> > > > Any thoughts or progress at this stage?  Are there further tests you need me
> > > > to do ?
> > > 
> > > Yes but you should expect two more days without signal.
> > 
> > FYI I am now back from annual leave and linux.conf.au.  This means I am in
> > a position to test possible solutions to this problem once you are able to
> > make them available.
> 
> Has there been any further progress on this problem?  I still have access to
> the hardware and systems if further tests are required.

To assist in picking up this issue I thought I'd summarise where things are
at from my perspective.

The problem is that small low-speed UDP packets are being dropped by the
r8169-based network card in our systems.  Git bisect showed that the
regression started with commit da78dbff2e05630921c551dbbc70a4b7981a8fff.

On 23 Nov 2015 Francois Romieu requested:

> If you can crash your system at will, you may apply the patch below to
> da78dbff2e05630921c551dbbc70a4b7981a8fff ("r8169: remove work from irq
> handler.") parent (aka 1e874e041fc7c222cbd85b20c4406070be1f687a) and
> build it in a current tree (say 4.2).

I did this (in a 4.3 tree) and the regression was resolved.  Following the
communuication on 2 Dec 2015 indicating there would be further news in a
couple of days, I haven't head anything else on the subject.

I am keen to resolve this problem as soon as possible as it will allow us to
move systems away from the ancient 2.6 kernel we are currently forced to use
as a result of this UDP regression (changing the network card for something
based on another chipset is not an option).  If there are further tests
needed to progress a fix please let me know as I still have an offline
system I can use for testing.

Regards
  jonathan
