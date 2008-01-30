From: Adrian Bunk <bunk@kernel.org>
Subject: Re: Mostly revert "e1000/e1000e: Move PCI-Express device IDs over
	to e1000e"
Date: Thu, 31 Jan 2008 01:58:36 +0200
Message-ID: <20080130235836.GV29368@does.not.exist>
References: <200801292359.m0TNxb75011826@hera.kernel.org> <20080129212314.91b9bb5b.randy.dunlap@oracle.com> <alpine.LFD.1.00.0801301631400.3426@www.l.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	auke-jan.h.kok@intel.com, jeff@garzik.org,
	"David S. Miller" <davem@davemloft.net>,
	akpm <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760998AbYA3X6S@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.00.0801301631400.3426@www.l.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 30, 2008 at 04:51:04PM +1100, Linus Torvalds wrote:
> 
> 
> On Tue, 29 Jan 2008, Randy Dunlap wrote:
> > 
> > Andrew was concerned about this when the driver was in -mm.
> > He asked for a patch that would set E1000E to same value as E1000
> > and I supplied that.  Auke acked it IIRC.  Other people vetoed it.  :(
> 
> Yeah, I've been discussing with Jeff and the gang.
> 
> I think we have agreed on a solution where the ID's show up in the old 
> driver if the new driver is not enabled at all.
> 
> (And as a side note: it turns out that the problem I experienced didn't 
> come from the new e1000e driver after all, so I'll be removing the 
> EXPERIMENTAL flag again).
> 
> So I'd suggest the final patch be something like this, but I'm sendign it 
> out just as an example of how we could solve this, not necessarily as a 
> final patch.
> 
> Jeff, Auke, would something like this be acceptable? It makes it very 
> obvious in the driver table which entries are for the PCIE versions that 
> would be handled by the E1000E driver if it is enabled..
> 
> Untested, but as mentioned, this is more of a "this looks maintainable and 
> like it should solve the issues" rather than anything I was planning on 
> committing now.

I don't like it:

We should aim at having exactly one driver for one card.

Your patch has effects like e.g. a kernel behaving differently when 
adding and compiling the e1000e module later compared to having it 
originally in the .config.

And fun like "The card works on my machine with the e1000 driver, why 
doesn't it work in your machine with the e1000 driver?".

And in terms of maintainability, people will disable the e1000e driver 
in their kernel for working around bugs in it instead of reporting the 
bugs. Exactly what we want to not happen.

And unless we want to keep this situation forever, we anyway have to 
remove the support for the PCI-Express adapters from the e1000 driver at 
some point in time, so why not make a clear cut now? Whatever problems 
this causes will be the same now or in a few years.

> 		Linus

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
