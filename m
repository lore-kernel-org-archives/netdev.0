From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: What should PCI core do during suspend-resume? (was: Re:
 2.6.29-rc3: tg3 dead after resume)
Date: Sat, 31 Jan 2009 17:06:47 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901311652500.3067@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901311516360.2978@localhost.localdomain> <alpine.LFD.2.00.0901311534340.3067@localhost.localdomain> <200902010136.55375.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36950 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753866AbZBABGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 20:06:53 -0500
In-Reply-To: <200902010136.55375.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sun, 1 Feb 2009, Rafael J. Wysocki wrote:
> 
> All this leads to the conclusion that we should put devices into low power
> states with interrupts off and this seems to imply that we'll need to make the
> AML interpreter allow us to run AML with interrupts off.

How many devices actually have the _PS3 method (or whatever it is that we 
end up executing)? We might be able to simply flag it, and say "ok, if we 
have a _PS3 method, we'll have to suspend early, otherwise we can leave it 
for a late suspend".

Definitely not perfect, but perhaps a way to get the safe thing on 99% of 
all cases, and have to live with the horrid ACPI rules on some things.

I thought the _DSW thing is common for setting up wakeup, but _PSx is not. 
But I have not looked at many ACPI tables in my life. I try to active 
avoid it if I at all humanly can.

			Linus
