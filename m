From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 07 Feb 2009 14:26:06 +1100
Message-ID: <1233977166.31963.63.camel@pasglop>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop>
	 <200901312208.20850.rjw@sisk.pl>
	 <alpine.LFD.2.00.0901311318570.4064@localhost.localdomain>
	 <200901312346.35265.rjw@sisk.pl>
	 <alpine.LFD.2.00.0901311450550.2978@localhost.localdomain>
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
Received: from gate.crashing.org ([63.228.1.57]:54779 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751661AbZBGD0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 22:26:53 -0500
In-Reply-To: <alpine.LFD.2.00.0901311450550.2978@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> Here's a big hint: YOU DO NOT KNOW. YOU MUST NOT TURN OFF THE BRIDGE AT 
> SUSPEND TIME!

A quick catch up on old emails ....

A good reason not to turn bridges off is that behind bridges, you'll
find more than your "normal" PCI devices. You'll find system devices,
things like your motherboard GPIO & clock control, i2c controllers,
service processors, your PIC, etc... 

And your BIOS will need them. Your ACPI stuff will indirectly access
these things, for example to get the machine into actual suspend state
etc...

Disabling bridges is bad :-)

If they have to be disabled for power management purposes, then it's
likely that ACPI/BIOS itself will do it at the very last minute when
going into S3, and bring them back itself on the way back.

For embedded platforms who want to override that, they can always stick
a driver there or do it manually from a sysdev or platform code.

IE. I very very much doubt windows does anything to bridges, appart
-maybe- saving/restoring the standard window settings -just-in-case-
they got wiped out and the BIOS didn't restore them.

Ben.


