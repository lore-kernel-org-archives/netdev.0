From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] vsprintf.c: Reduce sizeof struct printf_spec from 24 to
 8 bytes
Date: Sat, 6 Mar 2010 18:24:55 -0800 (PST)
Message-ID: <alpine.LFD.2.00.1003061818530.4033@localhost.localdomain>
References: <cover.1267682641.git.joe@perches.com>  <20100304143837.af39845d.akpm@linux-foundation.org>  <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain>  <1267911399.849.39.camel@Joe-Laptop.home>  <alpine.LFD.2.00.1003061356420.31447@localhost.localdomain>
  <1267914654.849.81.camel@Joe-Laptop.home>  <alpine.LFD.2.00.1003061445490.31447@localhost.localdomain>  <alpine.LFD.2.00.1003061455590.31447@localhost.localdomain>  <1267918554.849.89.camel@Joe-Laptop.home>  <alpine.LFD.2.00.1003061540470.23804@localhost.localdomain>
  <alpine.LFD.2.00.1003061547490.23804@localhost.localdomain>  <alpine.LFD.2.00.1003061556420.23804@localhost.localdomain> <1267924214.1937.12.camel@Joe-Laptop.home> <alpine.LFD.2.00.1003061755400.23804@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	Bjorn Helgaas <bjorn.helgaas@hp.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1003061755400.23804@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 6 Mar 2010, Linus Torvalds wrote:

> the 'pointer()' function has a 200+ byte stack footprint on x86-64. And 
> vsnprintf itself is about 100+ bytes. So that stack depth is way bigger 
> than I would have expected.
> 
> I'm not sure _why_ that stack footprint for 'pointer()' is so big, but I 
> bet it's due to some simple inlining, and gcc (once more) sucking at it 
> and not being able to combine stack frames. It's a damn shame.

Yeah, a few noinline's gets 'pointer()' to just save registers on the 
stack, no need for any extra buffers (which then is ok for your recursion 
case - the other subfunctions it can call have their own buffers, of 
course, but they won't be in the recursive call-path except at the leaf.

vsnprintf() itself seems less obviously fixable. I'm not sure wht gcc 
decides it needs 88 bytes of temp-space there.

		Linus
