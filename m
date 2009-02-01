From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: What should PCI core do during suspend-resume? (was: Re:
 2.6.29-rc3: tg3 dead after resume)
Date: Sat, 31 Jan 2009 17:20:05 -0800
Message-ID: <20090131172005.4f107d9e@infradead.org>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop>
	<alpine.LFD.2.00.0901311516360.2978@localhost.localdomain>
	<alpine.LFD.2.00.0901311534340.3067@localhost.localdomain>
	<200902010136.55375.rjw@sisk.pl>
	<alpine.LFD.2.00.0901311652500.3067@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
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
Received: from casper.infradead.org ([85.118.1.10]:36183 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbZBABUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 20:20:08 -0500
In-Reply-To: <alpine.LFD.2.00.0901311652500.3067@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 31 Jan 2009 17:06:47 -0800 (PST)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Sun, 1 Feb 2009, Rafael J. Wysocki wrote:
> > 
> > All this leads to the conclusion that we should put devices into
> > low power states with interrupts off and this seems to imply that
> > we'll need to make the AML interpreter allow us to run AML with
> > interrupts off.
> 
> How many devices actually have the _PS3 method (or whatever it is
> that we end up executing)? We might be able to simply flag it, and
> say "ok, if we have a _PS3 method, we'll have to suspend early,
> otherwise we can leave it for a late suspend".
> 

in this area there's a pet pieve of mine, or rather something that
shows up on kerneloops.org quite a bit:
There are several PCI quirks that get run with irqs off, but they are
just the "normal" boot time quirks, and when they get run there, they
can sleep. Some of them do things like call ioremap() and the like....
from memory some of the asus and via quirks come to mind...



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
