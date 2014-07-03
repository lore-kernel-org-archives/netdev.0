From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] declance: Fix 64-bit compilation warnings
Date: Wed, 02 Jul 2014 23:25:46 -0700
Message-ID: <1404368746.14741.36.camel@joe-AO725>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>
	 <20140702.182807.1245632778216212860.davem@davemloft.net>
	 <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>
	 <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
	 <1404356734.14741.18.camel@joe-AO725>
	 <alpine.LFD.2.11.1407030423300.15455@eddie.linux-mips.org>
	 <1404364565.14741.26.camel@joe-AO725>
	 <alpine.LFD.2.11.1407030637030.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0234.hostedemail.com ([216.40.44.234]:45735 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750707AbaGCGZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 02:25:50 -0400
In-Reply-To: <alpine.LFD.2.11.1407030637030.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-03 at 07:01 +0100, Maciej W. Rozycki wrote:
> On Wed, 2 Jul 2014, Joe Perches wrote:
> 
> > > > The kernel vsprintf implementation doesn't prefix
> > > > pointers with 0x, so you can use 0x%p if you really
> > > > want that with a leading prefix, but you don't have
> > > > to use it.
> > > 
> > >  It does, when the `#' format modifier is used (go try yourself!).
> > 
> > I know it does, but it's incidental.
> 
>  Is it?  Someone took the effort to handle it:
> 
> 	int default_width = 2 * sizeof(void *) + (spec.flags & SPECIAL ? 2 : 0);
> 
> while they could do:
> 
> 	int default_width = 2 * sizeof(void *);
> 
> 	spec.flags &= ~SPECIAL;

Grant Likely did that a couple of years ago.

commit 725fe002d315c2501c110b7245d3eb4f4535f4d6
Author: Grant Likely <grant.likely@secretlab.ca>
Date:   Thu May 31 16:26:08 2012 -0700

    vsprintf: correctly handle width when '#' flag used in %#p format
    
    The '%p' output of the kernel's vsprintf() uses spec.field_width to
    determine how many digits to output based on 2 * sizeof(void*) so that all
    digits of a pointer are shown.  ie.  a pointer will be output as
    "001A2B3C" instead of "1A2B3C".  However, if the '#' flag is used in the
    format (%#p), then the code doesn't take into account the width of the
    '0x' prefix and will end up outputing "0x1A2B3C" instead of "0x001A2B3C".
    
    This patch reworks the "pointer()" format hook to include 2 characters for
    the '0x' prefix if the '#' flag is included.

Not sure it ever mattered myself.

>  Hmm, actually I wonder if GCC maintainers could be persuaded to accept a 
> `linux_printk' format checker, that would accurately match our semantics 
> and could handle some of our other extensions too.  There are precedents 
> already, `cmn_err' and `CFString' (for Solaris and Darwin), so it's not 
> like a no-no outright.  WDYT?
> 

Maybe via a gcc plugin.

https://gcc.gnu.org/wiki/plugins

If you're going to write one, it'd be nice to validate all
the %p<foo> extensions too.
