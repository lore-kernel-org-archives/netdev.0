From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: [KJ] [KJ PATCH] Replacing alloc_pages(gfp, 0) with alloc_page(gfp)
 in net/core/pktgen.c
Date: Wed, 13 Jun 2007 09:14:55 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0706130912080.4392@localhost.localdomain>
References: <1181702562.2282.12.camel@shani-win>
 <a901b49a0706130312mba8a686m455b5cbf774cc159@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Shani Moideen <shani.moideen@wipro.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, jgarzik@pobox.com,
	kernel-janitors@lists.osdl.org
To: psr <pradeep.rautela@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:55473 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303AbXFMNRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 09:17:18 -0400
In-Reply-To: <a901b49a0706130312mba8a686m455b5cbf774cc159@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Jun 2007, psr wrote:

> On 6/13/07, Shani Moideen <shani.moideen@wipro.com> wrote:
> >
> > Replacing alloc_pages(gfp,0) with alloc_page(gfp)
> > in net/core/pktgen.c
> >
> > Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
> > ----
> >
> > diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> > index b92a322..2600c7f 100644
> > --- a/net/core/pktgen.c
> > +++ b/net/core/pktgen.c
> > @@ -2414,7 +2414,7 @@ static struct sk_buff *fill_packet_ipv4(struct
> > net_device *odev,
> >
> >                 i = 0;
> >                 while (datalen > 0) {
> > -                       struct page *page = alloc_pages(GFP_KERNEL, 0);
> > +                       struct page *page = alloc_page(GFP_KERNEL);
>
> Does this makes any difference anyway? Both are same eventually?
> What is the rational behind this? Can you please help me
> understanding this?

since this is one of the TO DO items i added to the list of things at
the wiki:

http://fsdev.net/wiki/index.php?title=Memory_allocation_cleanup

i'll just toss in my $0.02.  if a short (more convenient) form of a
routine has been defined, it should be used.  if you have no plans to
use it, it shouldn't have been defined in the first place.

in short, make a consistent decision and go with it.

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
