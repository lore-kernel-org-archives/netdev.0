From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PULL -tip] fixed few make headers_check warnings
Date: Wed, 14 Jan 2009 17:36:14 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0901141732450.26663@anakin>
References: <1231836016.3212.41.camel@jaswinder.satnam>
 <Pine.LNX.4.64.0901140954250.27308@anakin> <3f9a31f40901140129i1389f47frf32808f3a695a118@mail.gmail.com>
 <20090114153825.GB32082@uranus.ravnborg.org>
 <3f9a31f40901140759s1542e6cclae1808b796c2b1a9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sam Ravnborg <sam@ravnborg.org>,
	Jaswinder Singh Rajput <jaswinder@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	x86 maintainers <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wilson.telenet-ops.be ([195.130.132.42]:46244 "EHLO
	wilson.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758044AbZANQgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 11:36:18 -0500
In-Reply-To: <3f9a31f40901140759s1542e6cclae1808b796c2b1a9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jan 2009, Jaswinder Singh Rajput wrote:
> On Wed, Jan 14, 2009 at 9:08 PM, Sam Ravnborg <sam@ravnborg.org> wrote:
> > I appreciate your work but I will like to question the approach.
> 
> My approach was:
> "PATCH should solve a problem per file", like:
>  capability.h: extern's make no sense in userspace
>  coda_psdev.h: extern's make no sense in userspace
>  in6.h: extern's make no sense in userspace
>  nubus.h: extern's make no sense in userspace
>  socket.h: extern's make no sense in userspace
> 
> But this warnings was in many files:
>  include of <linux/types.h> is preferred over <asm/types.h> : 15 files
>  found __[us]{8,16,32,64} type without #include <linux/types.h> : 52 files
> 
> So in place of making 15 + 52 = 67 patches, I made 2 patches for each warning.
> 
> > We should rather take the warnings as an indication that this
> > file needs to be looked over and fix not only the warnings
> > reported but rater to fix all the questionable issues on a file-by-file basis.
> 
> Should I make 67 patches ?

No.

What Sam means is that the warnings about externs not making sense in userspace
are indicators that there may be other external declarations (without "extern")
in those files, and that you should fix those at the same time (i.e. either
don't fix any of them, or fix all of them (in the same file)). If you don't
fix them at the same time, people tend to forget about them.

So the warnings are just considered canaries in our coal mine. Killing only the
canaries doesn't help.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
