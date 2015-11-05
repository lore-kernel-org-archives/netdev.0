From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] decnet: remove macro-local declarations
Date: Thu, 05 Nov 2015 14:02:53 -0800
Message-ID: <1446760973.21133.92.camel@perches.com>
References: <1446718696-32505-1-git-send-email-Julia.Lawall@lip6.fr>
	 <20151105.142619.983467860147585345.davem@davemloft.net>
	 <alpine.DEB.2.02.1511052038400.2065@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lkp@intel.com,
	roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com
To: Julia Lawall <julia.lawall@lip6.fr>,
	David Miller <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1511052038400.2065@localhost6.localdomain6>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-11-05 at 20:38 +0100, Julia Lawall wrote:
> On Thu, 5 Nov 2015, David Miller wrote:
> > From: Julia Lawall <Julia.Lawall@lip6.fr>
> > Date: Thu,  5 Nov 2015 11:18:16 +0100> 
> > > Move the variable declarations from the for_nexthops macro to the
> > > surrounding context, so that it is clear where these variables are
> > > declared.  This also makes it possible to remove the endfor_nexthops macro.
> > > 
> > > This change adds new arguments to the macro for_nexthops.  They are ordered
> > > such that a pointer to the referenced object comes first, the index in the
> > > list comes next, and the list itself comes last, roughly in analogy with
> > > the list_for_each macros.
[]
> > > This patch takes care of a single file, where the macros are defined
> > > locally.  If the basic transformation looks OK, I will change the other
> > > files that either likewise define their own macros or use the macros in
> > > net/mpls/internal.h.  The potentially affected files are:
> >  ...
> > 
> > This looks fine to me.
> > 
> > Please resubmit this when net-next opens back up, which should be
> > shortly after -rc1.
> 
> OK, I'll do the others then too.

If you do can you please parenthesize the macro arguments?

#define for_nexthops(nh, nhsel, fi) \
 	for (nhsel = 0, nh = (fi)->fib_nh; nhsel < (fi)->fib_nhs; (nh)++, (nhsel)++)
instead of
	for(nhsel = 0, nh = (fi)->fib_nh; nhsel < (fi)->fib_nhs; nh++, nhsel++)

And perhaps a renaming might be better

	s/for_nexthops/for_each_nexthop/
