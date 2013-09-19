From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] stable_kernel_rules.txt: Exclude networking from stable
 rules
Date: Thu, 19 Sep 2013 14:45:30 -0700
Message-ID: <1379627130.5862.2.camel@joe-AO722>
References: <alpine.LRH.2.02.1309191229480.32035@file01.intranet.prod.int.rdu2.redhat.com>
	 <20130919.135628.1201613770803318193.davem@davemloft.net>
	 <alpine.LRH.2.02.1309191359300.12162@file01.intranet.prod.int.rdu2.redhat.com>
	 <1379615474.22168.13.camel@joe-AO722>
	 <20130919213241.GB31672@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, Mikulas Patocka <mpatocka@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rob Landley <rob@landley.net>, linux-doc@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130919213241.GB31672@electric-eye.fr.zoreil.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-09-19 at 23:32 +0200, Francois Romieu wrote:
> Joe Perches <joe@perches.com> :
> [...]
> > diff --git a/Documentation/stable_kernel_rules.txt b/Documentation/stable_kernel_rules.txt
> > index b0714d8..a2d6da0 100644
> > --- a/Documentation/stable_kernel_rules.txt
> > +++ b/Documentation/stable_kernel_rules.txt
> > @@ -29,6 +29,11 @@ Rules on what kind of patches are accepted, and which ones are not, into the
> >  
> >  Procedure for submitting patches to the -stable tree:
> >  
> > + - The networking tree (net/ and drivers/net/) is 'special' and doesn't
> > +   follow the rules below.  Don't send or cc: patches for the -stable tree to
> > +   stable@vger.kernel.org.  Don't mark them stable.  Just send the patches to
> > +   netdev@vger.kernel.org and let the networking maintainer decide what to do
> > +   with them.
> 
> David said "simply ask me to queue them up for -stable explicitly".
> 
> He did not say "send the patches and let me decide what to do with them".
> 

David selects them regardless.

from Documentation/networking/netdev-FAQ.txt:

Q: How can I tell what patches are queued up for backporting to the
   various stable releases?

A: Normally Greg Kroah-Hartman collects stable commits himself, but
   for networking, Dave collects up patches he deems critical for the
   networking subsystem, and then hands them off to Greg.

   There is a patchworks queue that you can see here:
	http://patchwork.ozlabs.org/bundle/davem/stable/?state=*

   It contains the patches which Dave has selected, but not yet handed
   off to Greg.  If Greg already has the patch, then it will be here:
	http://git.kernel.org/cgit/linux/kernel/git/stable/stable-queue.git

   A quick way to find whether the patch is in this stable-queue is
   to simply clone the repo, and then git grep the mainline commit ID, e.g.

	stable-queue$ git grep -l 284041ef21fdf2e
	releases/3.0.84/ipv6-fix-possible-crashes-in-ip6_cork_release.patch
	releases/3.4.51/ipv6-fix-possible-crashes-in-ip6_cork_release.patch
	releases/3.9.8/ipv6-fix-possible-crashes-in-ip6_cork_release.patch
	stable/stable-queue$

Q: I see a network patch and I think it should be backported to stable.
   Should I request it via "stable@vger.kernel.org" like the references in
   the kernel's Documentation/stable_kernel_rules.txt file say?

A: No, not for networking.  Check the stable queues as per above 1st to see
   if it is already queued.  If not, then send a mail to netdev, listing
   the upstream commit ID and why you think it should be a stable candidate.

   Before you jump to go do the above, do note that the normal stable rules
   in Documentation/stable_kernel_rules.txt still apply.  So you need to
   explicitly indicate why it is a critical fix and exactly what users are
   impacted.  In addition, you need to convince yourself that you _really_
   think it has been overlooked, vs. having been considered and rejected.

   Generally speaking, the longer it has had a chance to "soak" in mainline,
   the better the odds that it is an OK candidate for stable.  So scrambling
   to request a commit be added the day after it appears should be avoided.

Q: I have created a network patch and I think it should be backported to
   stable.  Should I add a "Cc: stable@vger.kernel.org" like the references
   in the kernel's Documentation/ directory say?

A: No.  See above answer.  In short, if you think it really belongs in
   stable, then ensure you write a decent commit log that describes who
   gets impacted by the bugfix and how it manifests itself, and when the
   bug was introduced.  If you do that properly, then the commit will
   get handled appropriately and most likely get put in the patchworks
   stable queue if it really warrants it.

   If you think there is some valid information relating to it being in
   stable that does _not_ belong in the commit log, then use the three
   dash marker line as described in Documentation/SubmittingPatches to
   temporarily embed that information into the patch that you send.



