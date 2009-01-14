From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PULL -tip] fixed few make headers_check warnings
Date: Wed, 14 Jan 2009 21:15:13 +0100
Message-ID: <20090114201513.GC1556@uranus.ravnborg.org>
References: <1231836016.3212.41.camel@jaswinder.satnam> <Pine.LNX.4.64.0901140954250.27308@anakin> <3f9a31f40901140129i1389f47frf32808f3a695a118@mail.gmail.com> <20090114153825.GB32082@uranus.ravnborg.org> <3f9a31f40901140759s1542e6cclae1808b796c2b1a9@mail.gmail.com> <Pine.LNX.4.64.0901141732450.26663@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>,
	Jaswinder Singh Rajput <jaswinder@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	x86 maintainers <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfepa.post.tele.dk ([195.41.46.235]:46740 "EHLO
	pfepa.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757363AbZANUNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 15:13:33 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0901141732450.26663@anakin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 05:36:14PM +0100, Geert Uytterhoeven wrote:
> On Wed, 14 Jan 2009, Jaswinder Singh Rajput wrote:
> > On Wed, Jan 14, 2009 at 9:08 PM, Sam Ravnborg <sam@ravnborg.org> wrote:
> > > I appreciate your work but I will like to question the approach.
> > 
> > My approach was:
> > "PATCH should solve a problem per file", like:
> >  capability.h: extern's make no sense in userspace
> >  coda_psdev.h: extern's make no sense in userspace
> >  in6.h: extern's make no sense in userspace
> >  nubus.h: extern's make no sense in userspace
> >  socket.h: extern's make no sense in userspace
> > 
> > But this warnings was in many files:
> >  include of <linux/types.h> is preferred over <asm/types.h> : 15 files
> >  found __[us]{8,16,32,64} type without #include <linux/types.h> : 52 files
> > 
> > So in place of making 15 + 52 = 67 patches, I made 2 patches for each warning.
> > 
> > > We should rather take the warnings as an indication that this
> > > file needs to be looked over and fix not only the warnings
> > > reported but rater to fix all the questionable issues on a file-by-file basis.
> > 
> > Should I make 67 patches ?
> 
> No.
> 
> What Sam means is that the warnings about externs not making sense in userspace
> are indicators that there may be other external declarations (without "extern")
> in those files, and that you should fix those at the same time (i.e. either
> don't fix any of them, or fix all of them (in the same file)). If you don't
> fix them at the same time, people tend to forget about them.
> 
> So the warnings are just considered canaries in our coal mine. Killing only the
> canaries doesn't help.

Correct. We should use the warnings to tell us that there may be something
fishy here and fix it all.
I've used checkpatch in the same way occasionally. If I had to do some
cleanup and checkpatch was a bit noisy I went through the file
_manually_. And when finished I ran chackpatch again and fixed up the
warnings/errors that made sense for me to fix and that I forgot when I refactored
the code.

So when I see "capability.h: extern's make no sense in userspace"
the perfect approach would be that the whole file was checked.

This is a much bigger task that just removing the warning.

(All this said I have sometimes doen the "remove warnings only trick too").

	Sam
