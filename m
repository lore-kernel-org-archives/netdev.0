From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RESEND PATCH 0/2] Make functions of dev_<level> macros, recursive
 vsnprintf
Date: Sat, 6 Mar 2010 14:52:55 -0800 (PST)
Message-ID: <alpine.LFD.2.00.1003061445490.31447@localhost.localdomain>
References: <cover.1267682641.git.joe@perches.com>  <20100304143837.af39845d.akpm@linux-foundation.org>  <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain>  <1267911399.849.39.camel@Joe-Laptop.home>  <alpine.LFD.2.00.1003061356420.31447@localhost.localdomain>
 <1267914654.849.81.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267914654.849.81.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 6 Mar 2010, Joe Perches wrote:
> 
> Maybe limit the %pV recursion depth to 1 with something like:
> (in vsprintf.c: pointer() )

Nope. Think about concurrent users.

The thing is, you have to hide it in local storage. We could make it 
thread-local (not cpu-local), but even that interacts badly with 
interrupts.

The only really workable approach would be to have a stack slot that is 
created by the externally visible routines (and initialized to zero), and 
those then passe the address of that as an argument to the lower levels, 
and then the recursion happens entirely within those lower level functions 
that update the value.

So it's doable, it's just not pretty.

> > and I'd also love to see some actual numbers of > > how deep the vsnprintf stack frame is, but I don't see how to do the 
> > first, and I'm hoping the second isn't too horrible.
> 
> I believe it's the arguments, a long long, a couple of pointers,
> and a struct printf_spec.  Not too bad.

I'm not convinced. We pass that 'printf_spec' around a lot, including 
nesting. Not as a pointer, either.

(Bjorn Helgaas has a patch that gets rid of _some_ of the stack usage, but 
not nearly all).

		Linus
