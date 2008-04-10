From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Thu, 10 Apr 2008 14:23:50 -0700
Message-ID: <47FE8566.5040809@intel.com>
References: <20080408193245.GG11962@parisc-linux.org> <20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org> <20080408200652.GC28148@elte.hu> <47FBD34A.6080508@garzik.org> <20080408203314.GA28952@elte.hu> <47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu> <47FD2325.2030705@intel.com> <47FE5C89.5060209@intel.com> <20080410192714.GA14055@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, Matthew Wilcox <matthew@wil.cx>,
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
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759256AbYDJV11@vger.kernel.org>
In-Reply-To: <20080410192714.GA14055@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
> * Kok, Auke <auke-jan.h.kok@intel.com> wrote:
> 
>>>>  config E1000E_ENABLED
>>>> -	def_bool E1000E != n
>>>> +	def_bool E1000E = y || ((E1000E != n) && (E1000 = E1000E))
>>> Uh, that's /not/ what Ingo's patch does.  His patch makes e1000 
>>> claim the e1000e IDs if e1000 is built-in and e1000e is a module.
>> so that's definately _not_ what I would like to see at all. Matthew 
>> points out that this will just prolong users to use e1000 instead of 
>> e1000e (which is what they should be encouraged to switch to in those 
>> cases).
>>
>> so I'm dropping my ACK
> 
> why you want to cripple an existing, rather well working and popular 
> Linux driver is beyond me.

Because we decided a long time ago to do this driver split. And everyone at that
time agreed with that, and we set out to do this. And part of that plan was to
move (not copy) the device IDs over.

We accepted that that might break some kernel developers' systems in the process
and consulted several vendors and distros if they were OK with the change and they
all agreed with the plan.

I do not want people with PCI Express e1000 cards to use e1000 for any day longer
than is strictly needed, and I certainly do not want to prolong the period where
both drivers could work on their adapters. That will be a far bigger nightmare for
me than just a few kernel developers having a bad day.

I guarantee, I will get e-mails about 2.6.25+e1000(e) issues for far longer then
you guys :)

Users will outnumber us kernel developers in complaints if we keep the situation
unclear to them, and we already told them that they need to switch to e1000e for
their PCI Express devices. If we now do stuff like what you proposed in that
patch, we just prolong this confusion. That cannot be good for anyone. Imagine if
distro's start picking random device IDs or worse. Stuff like that is already
happening, and discussions like these just add to the confusion.

Again - If there is a way to auto-enable e1000e in the right way so that more
systems migrate better then I'm all for it (even if forcing E1000E=y). But it
seems that the various patches proposed don't cut it and frankly Kconfig is
completely inadequate as a hardware enabling script since it knows absolutely
nothing about the hardware in the first place. And it wasn't meant for that
either. `make oldconfig` is not the answer ;).

Again - this has happened before, I remember many of my boxes not booting because
SATA Kconfig options changed and all my boxes failed to move the proper Kconfig
symbols over when I ran `make oldconfig` myself. Somewhere around 2.6.20 or so.



Auke
