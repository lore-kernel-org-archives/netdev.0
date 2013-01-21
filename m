From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: IPsec AH use of ahash
Date: Mon, 21 Jan 2013 10:28:33 -0500
Message-ID: <1358782113.21576.28.camel@gandalf.local.home>
References: <1731098824.95194.1358779862449.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Dillow <dave@thedillows.org>, Borislav Petkov <bp@alien8.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:18113 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838Ab3AUP2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 10:28:35 -0500
In-Reply-To: <1731098824.95194.1358779862449.JavaMail.root@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-21 at 09:51 -0500, Tom St Denis wrote:
> 
> ----- Original Message -----
> > From: "Steven Rostedt" <rostedt@goodmis.org>
> > To: "Tom St Denis" <tstdenis@elliptictech.com>
> > Cc: "David Dillow" <dave@thedillows.org>, "Borislav Petkov" <bp@alien8.de>, linux-kernel@vger.kernel.org,
> > netdev@vger.kernel.org
> > Sent: Monday, 21 January, 2013 9:37:41 AM
> > Subject: Re: IPsec AH use of ahash
> > > 
> > > I find that 73% of all stats are made up.
> > 
> > I was only talking about my own experience. I gave no numbers.
> 
> That was a joke.  You assumed that because I don't trim whitespace from multi-line comments [among other asinine code style issues] that I'm a bad developer.  Yet what actually happened was a build configuration error in which the file wasn't being compiled fully.

Heh, I got it. My point was that sloppy coding usually comes with
mistakes. I wasn't saying that your code is sloppy, or that all code
that checkpatch fails on is sloppy. But it's a way to clean things up.

Actually, there's been several times I found that cleaning up code that
checkpatch told me to fix, I would find a bug. Usually a silly error,
but something that would have needed to be fixed.

> 
> Let it go.

It's gone.

> > 
> > Some of checkpatch'es complaints are annoying. I'll grant you that.
> > And
> > checkpatch is more of a guideline than a strict rule. It's up to the
> > maintainer of the code to determine how much checkpatch should be
> > enforced.
> 
> That's not the impression I got from this weekends exchange.  

It's also up to the maintainer. Some maintainers are stricter than
others. And if they find that checkpatch is helpful, they may be more
inclined to push harder.

> 
> > For example, checkpatch complains on code like:
> > 
> > +       asm volatile (
> > +#ifdef CONFIG_X86_64
> > +                       "       xchg   %%rbx,%%rsp      \n"
> > +#else
> > +                       "       xchgl   %%ebx,%%esp     \n"
> > +#endif
> > +                       "       int3                    \n"
> > +                       "       .globl jprobe_return_end\n"
> > +                       "       jprobe_return_end:      \n"
> > +                       "       nop                     \n"::"b"
> > +                       (kcb->jprobe_saved_sp):"memory");
> > 
> > Because the white space before the '\n' is not needed. But adding
> > that
> > whitespace makes it easier to read the assembly.
> 
> So who gets to decide when/where to deviate from the rules?  

The maintainer does.

>  
> > When enforcing checkpatch makes the code less readable, that's when
> > it
> > should be ignored. But again, that's really up to the maintainer of
> > the
> > code to decide.
> 
> So we divine what the maintainer wants and doesn't want when we submit patches?  I think for me I'm going to follow them literally for now to avoid issues. 

The differences are really minor. And yes, sometimes you don't find out
until you send a patch to the maintainer. I've had to change patches to
others code because of this. But really, I never thought it was a big
deal. As a maintainer myself, I know that I want the code that I
maintain to be a certain way, because that makes me more efficient in
understanding the code. And I need to understand code that I didn't
write.

When I send a patch to another maintainer, and they tell me to fix the
way I did the comments, I don't complain. I fix the comments and resend.

-- Steve
