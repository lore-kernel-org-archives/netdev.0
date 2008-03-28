From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.25-rc7-git2: Reported regressions from 2.6.24
Date: Fri, 28 Mar 2008 10:46:12 -0700
Message-ID: <20080328104612.2641fb74.akpm@linux-foundation.org>
References: <200803272353.51901.rjw@sisk.pl>
	<alpine.LFD.1.00.0803271859280.14670@woody.linux-foundation.org>
	<Pine.LNX.4.64.0803272002090.11979@schroedinger.engr.sgi.com>
	<alpine.LFD.1.00.0803272050290.14670@woody.linux-foundation.org>
	<47ECCD17.7080908@artcom.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Lameter <clameter@sgi.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	LKML <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	netdev@vger.kernel.org
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@artcom.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756974AbYC1RrK@vger.kernel.org>
In-Reply-To: <47ECCD17.7080908@artcom.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Mar 2008 11:48:55 +0100 Pawe__ Staszewski <pstaszewski@artcom.pl> wrote:

> Linus Torvalds pisze:
> > On Thu, 27 Mar 2008, Christoph Lameter wrote:
> >   
> >> Slab allocations can never use GFP_HIGHMEM.
> >>     
> >
> > Totally irrelevant.
> >
> > The page allocation path does
> >
> >         if (gfp_flags & __GFP_ZERO)
> >                 prep_zero_page(page, order, gfp_flags);
> >
> > and that will cause a warning REGARDLESS of whether the page is a HIGHMEM 
> > page or not.
> >
> > And the fact is, passing in GFP_ZERO from the SLUB code is a bug 
> > regardless, because it unnecessarily does the dual memset().
> >
> > So here's a damn big clue:
> >  - SLUB does its own GFP_ZERO handling
> >  - so passing GFP_ZERO down to the page allocator is a f*cking bug
> >  - and this has NOTHING what-so-ever to do with GFP_HIGHMEM or even 
> >    whether the warning is "valid" or not - it's a bug even if the warning 
> >    had never happened.
> >
> > So stop blathering, and just admit that this was buggy. It was also 
> > fundamentally fragile to leave GFP_ZERO around when it was known to not be 
> > valid at that point (exactly because GFP_ZERO was handled by the caller).
> >
> > 		Linus
> >
> >
> >   
> Sorry for offtopic but i have the same problem with kernels 2.6.25-*
> like:
> http://kerneltrap.org/mailarchive/linux-netdev/2008/3/27/1274804
> http://kerneltrap.org/mailarchive/linux-netdev/2008/3/27/1270334
> 
> I search linux-netdev and found this links.
> I only sugest that 
> 
> 	Denys Fedoryshchenko
> 
> can have the same problem that i have with this kernels.
> I must revert my all kernels to 2.6.23.11 to get stable work on high (ip 
> traffic) loads.
> 
> And there is no documentation for LRO... and Stephen Hemminger write me 
> that LRO is not compatible with bridgeing and routing.
> see this link:
> http://bugzilla.kernel.org/show_bug.cgi?id=10335
> 
> 
> So there must be some documentation for this ... because people can have 
> many problems with this.
> 

These are all networking things, so let's cc that list.

> 
> Sorry for offtopic but this can resolve problems like my and Denys .

It's very on-topic - thanks for the reminder.

Rafael, are these things actually on the list?
