From: Ingo Molnar <mingo@elte.hu>
Subject: [patch] e1000=y && e1000e=m regression fix (was: Re: [regression]
	e1000e broke e1000)
Date: Wed, 9 Apr 2008 21:38:50 +0200
Message-ID: <20080409193850.GA11763@elte.hu>
References: <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu> <20080408193245.GG11962@parisc-linux.org> <20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org> <20080408200652.GC28148@elte.hu> <47FBD34A.6080508@garzik.org> <20080408203314.GA28952@elte.hu> <47FBDBE9.9040700@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <matthew@wil.cx>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Greg KH <greg@kroah.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:43691 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757801AbYDITj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 15:39:27 -0400
Content-Disposition: inline
In-Reply-To: <47FBDBE9.9040700@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Jeff Garzik <jeff@garzik.org> wrote:

>> We've got three thousand Kconfig options - it is clearly not 
>> realistic for users to keep such details in mind to avoid pitfalls.
>
> Agreed -- hence the multiple announcements, including in this thread, 
> to put said details into mind.

which part of "it took a kernel developer more than an hour to figure 
out why his laptop had a dead network interface" did you not understand? 
Whatever you did, it was not apparent to me. I dont follow every tiny 
detail of the e1000 driver family, nor do 99%+ [*] of our users.

find the fix below, against current -git.

the current upstream behavior is the worst possible one and is just a 
plain bug, and the solution is dead-simple.

	Ingo

[*] guesstimate

--------------->
Subject: e1000=y && e1000e=m regression fix
From: Ingo Molnar <mingo@elte.hu>
Date: Wed Apr 09 21:09:35 CEST 2008

fix a regression from v2.6.24: do not transfer the e1000e PCI IDs from 
e1000 to e1000e if e1000 is built-in and e1000e is a module.

Built-in drivers take precedence over modules in many ways - and in this 
case it's clear that the user intended the e1000 driver to be the 
primary one. "Silently change behavior and break existing configs" is 
never a good migration strategy. Most users will use distro kernels that 
are not affected by this problem at all - nor are they affected by this 
patch - but this problem can hit users and developers who build their 
kernels themselves and migrate from v2.6.24 to v2.6.25.

this fixes: http://bugzilla.kernel.org/show_bug.cgi?id=10427

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 drivers/net/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-x86.q/drivers/net/Kconfig
===================================================================
--- linux-x86.q.orig/drivers/net/Kconfig
+++ linux-x86.q/drivers/net/Kconfig
@@ -2022,7 +2022,7 @@ config E1000E
 	  will be called e1000e.
 
 config E1000E_ENABLED
-	def_bool E1000E != n
+	def_bool E1000E = y || ((E1000E != n) && (E1000 = E1000E))
 
 config IP1000
 	tristate "IP1000 Gigabit Ethernet support"
