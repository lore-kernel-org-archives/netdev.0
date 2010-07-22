From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] Re: mmotm 2010-07-19 - e1000e vs. pm_qos_update_request issues
Date: Thu, 22 Jul 2010 23:58:42 +0200
Message-ID: <201007222358.43222.rjw@sisk.pl>
References: <201007200007.o6K07Xbg028863@imap1.linux-foundation.org> <20100721091200.40c43158@schatten.dmk.lab> <4222.1279771503@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	mark gross <markgross@thegnar.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:49621 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754099Ab0GVWAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 18:00:23 -0400
In-Reply-To: <4222.1279771503@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, July 22, 2010, Valdis.Kletnieks@vt.edu wrote:
> On Wed, 21 Jul 2010 09:12:00 +0200, Florian Mickler said:
> 
> > Attached patch moves the registering from e1000_up to e1000_open and
> > the unregistering from e1000_down to e1000_close. 
> > It is only compile-tested as I don't have the hardware.
> 
> My laptop has the hardware, so I tested it - system does indeed boot
> without whinging about this issue.  Feel free to stick in a:
> 
> Tested-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>
> 
> Thanks for the fast fix. :)

I'm going to add the patch to the suspend-2.6 tree.  Any objections?

> > From 693c71b911ff0845c872261d5704a1d40960722d Mon Sep 17 00:00:00 2001
> > From: Florian Mickler <florian@mickler.org>
> > Date: Wed, 21 Jul 2010 08:44:21 +0200
> > Subject: [PATCH] e1000e: register pm_qos request on hardware activation
> > 
> > The pm_qos_add_request call has to register the pm_qos request with the pm_qos
> > susbsystem before first use of the pm_qos request via
> > pm_qos_update_request.
> > 
> > As pm_qos changed to use plists there is no benefit in registering and
> > unregistering the pm_qos request on ifup/ifdown and thus we move the
> > registering into e1000_open and the unregistering in e1000_close.

Rafael
