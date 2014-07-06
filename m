From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] vsprintf: Remove SPECIAL from pointer types
Date: Sun, 06 Jul 2014 07:32:40 -0700
Message-ID: <1404657160.27043.29.camel@joe-AO725>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>
	 <20140702.182807.1245632778216212860.davem@davemloft.net>
	 <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>
	 <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
	 <1404356734.14741.18.camel@joe-AO725>
	 <alpine.LFD.2.11.1407030423300.15455@eddie.linux-mips.org>
	 <1404364565.14741.26.camel@joe-AO725>
	 <alpine.LFD.2.11.1407030637030.15455@eddie.linux-mips.org>
	 <1404368746.14741.36.camel@joe-AO725>
	 <alpine.LFD.2.11.1407051529040.15455@eddie.linux-mips.org>
	 <1404576420.6384.41.camel@joe-AO725>
	 <alpine.LFD.2.11.1407051833400.15455@eddie.linux-mips.org>
	 <1404583739.6384.51.camel@joe-AO725>
	 <alpine.LFD.2.11.1407051917480.15455@eddie.linux-mips.org>
	 <1404585099.6384.53.camel@joe-AO725>
	 <alpine.LFD.2.11.1407052103130.15455@eddie.linux-mips.org>
	 <1404593114.6384.72.camel@joe-AO725>
	 <alpine.LFD.2.11.1407061222270.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0191.hostedemail.com ([216.40.44.191]:33686 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751492AbaGFOco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2014 10:32:44 -0400
In-Reply-To: <alpine.LFD.2.11.1407061222270.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-07-06 at 12:44 +0100, Maciej W. Rozycki wrote:
> On Sat, 5 Jul 2014, Joe Perches wrote:
> 
> > Because gcc issues a complaint about any pointer format with %#p,
> > remove the use of SPECIAL to prefix 0x to various pointer types.
[]
>  Conceptually good, thanks for your effort, but you still need to clear 
> SPECIAL in `pointer' and maybe elsewhere, as that'll have been set for the 
> case concerned in `format_decode' by this code:
> 
> 		case '#': spec->flags |= SPECIAL; break;
> 
> (that doesn't check what follows) and then respected once `number' is 
> reached.  E.g.:
> 
> char *pointer(const char *fmt, char *buf, char *end, void *ptr,
> 	      struct printf_spec spec)
> {
> 	int default_width = 2 * sizeof(void *);
> 
> 	spec.flags &= ~SPECIAL;
> 
> or suchlike.  Sorry to have been unclear about it.

I think you're not right here.
The patch shouldn't remove the capability to prefix.

But neither am I right with the commit log actually.
It should say something like "remove the default extra
width for the 0x prefix from %#p".

Actually, I'm not sure that removing "SPECIAL adds
the pointer prefix length" to width is that good.

I think it doesn't matter much.

I do like removing the prefix it from %pa though.

linux's printf like capability is not exactly like
gcc's.  It doesn't have to be.  linux's implementation
already does not prefix 0x to pointers when gcc does.
gcc uses '(nil)', linux '(null)', etc.

And linux's variant does a bunch of extended outputs
for %p<foo> variants where it overrides any size and
prefixing specified.

The only difference introduced by the proposed patch
here is that a generic pointer type will now have a
variable output width if %#p is used depending on the
high two bytes of the pointer value if a size is not
specified.

fyi: gcc will output a prefix 0x with %#p just as it
     does for %p.

The major difference is that linux uses a default of
sizeof(void *) * 2 for the width and zero fills without
prefix, gcc defaults to the minimum # of chars required
and prefixes.

cheers, Joe
