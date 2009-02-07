From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 07 Feb 2009 14:27:26 +1100
Message-ID: <1233977246.31963.64.camel@pasglop>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop>
	 <200901312346.35265.rjw@sisk.pl>
	 <alpine.LFD.2.00.0901311450550.2978@localhost.localdomain>
	 <200902010111.08433.rjw@sisk.pl>
	 <alpine.LFD.2.00.0901311623520.3067@localhost.localdomain>
	 <alpine.LFD.2.00.0901311639530.3067@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Parag Warudkar <parag.lkml@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54798 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751661AbZBGD1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 22:27:41 -0500
In-Reply-To: <alpine.LFD.2.00.0901311639530.3067@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-01-31 at 16:51 -0800, Linus Torvalds wrote:
> 
> On Sat, 31 Jan 2009, Linus Torvalds wrote:
> > 
> > For a USB host controller, for example, it really could make sense to do 
> > that - just leave all the core host controller stuff running, and the only 
> > thing the "suspend()" callback does is to send the commands to the actual 
> > devices, it doesn't necessarily touch the host controller itself at all.
> 
> Same is quite likely true of things like video graphics adapters. Again, 
> for all the same reasons. Think about all those fbcon drivers. They will 
> use DMA for things. And again, there are very compelling debugging reasons 
> to not suspend them for real until suspend_late (if even then).

Actually, there are things like service processors etc... that only know
to communicate via DMA and little else via a little mailbox in some
reserved area of system memory...

Ben.


