From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH v2] declance: Fix 64-bit compilation warnings
Date: Thu, 3 Jul 2014 07:01:05 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1407030637030.15455@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>         <20140702.182807.1245632778216212860.davem@davemloft.net>         <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>         <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
         <1404356734.14741.18.camel@joe-AO725>         <alpine.LFD.2.11.1407030423300.15455@eddie.linux-mips.org> <1404364565.14741.26.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:51027 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689AbaGCGBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 02:01:07 -0400
Received: from localhost.localdomain ([127.0.0.1]:39485 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6816877AbaGCGBFkUmku (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 08:01:05 +0200
In-Reply-To: <1404364565.14741.26.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Jul 2014, Joe Perches wrote:

> > > The kernel vsprintf implementation doesn't prefix
> > > pointers with 0x, so you can use 0x%p if you really
> > > want that with a leading prefix, but you don't have
> > > to use it.
> > 
> >  It does, when the `#' format modifier is used (go try yourself!).
> 
> I know it does, but it's incidental.

 Is it?  Someone took the effort to handle it:

	int default_width = 2 * sizeof(void *) + (spec.flags & SPECIAL ? 2 : 0);

while they could do:

	int default_width = 2 * sizeof(void *);

	spec.flags &= ~SPECIAL;

instead (clearing the flag to suit `number' called later on, that is).  
And I actually find it a natural consequence of how we implement `%p'; 
using `#' to switch between the two formats seems to fit ISO C perfectly 
(as an extension, that is, of course, but that does not contradict the 
requirement of "undefined behaviour").

 Hmm, actually I wonder if GCC maintainers could be persuaded to accept a 
`linux_printk' format checker, that would accurately match our semantics 
and could handle some of our other extensions too.  There are precedents 
already, `cmn_err' and `CFString' (for Solaris and Darwin), so it's not 
like a no-no outright.  WDYT?

> I phrased it badly though.
> There's no code that uses it.
> 
> $ git grep "%#p" | wc -l
> 0

 Yeah, I did this before too; no surprise given the warning GCC produces.

> > I think using 0x%p 
> > would be ugly; here it wouldn't really matter, but ordinarily allowing a 
> > format to produce `0x (null)' would be rather lame, so I don't want to 
> > spread examples someone might foolishly copy.
> 
> $ git grep "0x%p" | wc -l
> 1747
> 
> <shrug>  What's one more...

 Heh, see what I mean.  And somehow I don't feel compelled to follow 1747 
mistakes. ;)  We could fix them all though if we had a proper 
`linux_printk' checker though.

  Maciej
