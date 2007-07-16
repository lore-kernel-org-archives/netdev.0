From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] [IrDA] Fix IrDA build failure
Date: Mon, 16 Jul 2007 17:16:05 +0200
Message-ID: <20070716151604.GB16474@uranus.ravnborg.org>
References: <20070716111715.GB22757@mail.solidboot.com> <20070716115624.GA4492@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <samuel.ortiz@solidboot.com>, davem@davemloft.net,
	eric.y.miao@gmail.com, netdev@vger.kernel.org,
	irda-users@lists.sourceforge.net, stable@kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:58890 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756039AbXGPPP1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 11:15:27 -0400
Content-Disposition: inline
In-Reply-To: <20070716115624.GA4492@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 16, 2007 at 03:56:26PM +0400, Evgeniy Polyakov wrote:
> Hi Samuel.
> 
> On Mon, Jul 16, 2007 at 02:17:15PM +0300, Samuel Ortiz (samuel.ortiz@solidboot.com) wrote:
> > This is due to the irda_init fix recently added, where we call __exit
> > routines from an __init one. It is a build failure that I didn't catch
> > because it doesn't show up when building IrDA as a module. My apologies
> > for that.
> 
> What about having all of them __devinit/__devexit?

__devinit is used to say that this funtion is used for hotplug so place this
in section .init.text only if !HOTPLUG.

So with __devinit/__devexit we would see exactly the same in the !HOTPLUG
case but only make it harder to trigger since the normal build has
HOTPLUG enabled.

New version of modpost will btw. catch these kind of errors so also in the
x86 case we will be notified - but then only as a warning not as an error.

	Sam
