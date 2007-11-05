From: Radu Rendec <radu.rendec@ines.ro>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Mon, 05 Nov 2007 18:12:46 +0200
Message-ID: <1194279167.2987.168.camel@localhost.localdomain>
References: <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost>
	 <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl>
	 <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost>
	 <20071105091231.GA1933@ff.dom.local>
	 <1194267561.2987.141.camel@localhost.localdomain>
	 <1194270212.4438.95.camel@localhost>  <20071105144959.GD1933@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-173-Unkn.Local.iNES.RO ([80.86.100.173]:42024 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750824AbXKEQOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 11:14:48 -0500
In-Reply-To: <20071105144959.GD1933@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-11-05 at 15:49 +0100, Jarek Poplawski wrote:
> > Yes, that example i believe would work just fine today as is with no
> > changes.
> ...
> > Please try the patch i sent since it is simpler. It is your work more or
> > less - so you should get the credit as author. 
> 
> Jamal + Houston, we have a problem...
> ...Or talk about different things or patches...
> 
> IMHO, both 'today as is' and your 1-st proposal get this example
> wrong: we need 00.00.00.ff at the end, don't we? 
> 
> Jarek P.

"Today as is" certainly doesn't work with masks extending across byte
boundary. I think Jarek's example (with all "1" bits in nibbles) is the
most straightforward to illustrate this.

Jarek, after I had replied you earlier, I figured out it can indeed be
solved with two shifts, but results need to be masked separately and
then merged to properly align resulting bits. Of course, this is my idea
about the two shifts, maybe you thought of something else.

On the other hand, after a quick browsing through a lxr, it seems that
(at least on i386) ntohl() is actually a swab32(), which is defined in
include/asm-i386/byteorder.h on line 13. In the worst scenario (with
CONFIG_X86_BSWAP being undefined) it's done in 3 instructions (asm
level). It may actually be faster than the two shift approach in C.

Jamal, sometime later in the evening I'll try the patch you sent,
although my guess is that it won't work (most probably it will produce
what Jarek suggested earlier). What exactly did you mean by "cutdown on
the conversion in u32_change()"?

Cheers,
Radu Rendec


