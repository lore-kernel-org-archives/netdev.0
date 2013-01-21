From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: IPsec AH use of ahash
Date: Mon, 21 Jan 2013 09:51:02 -0500 (EST)
Message-ID: <1731098824.95194.1358779862449.JavaMail.root@elliptictech.com>
References: <1358779061.21576.19.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Dillow <dave@thedillows.org>, Borislav Petkov <bp@alien8.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358779061.21576.19.camel@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



----- Original Message -----
> From: "Steven Rostedt" <rostedt@goodmis.org>
> To: "Tom St Denis" <tstdenis@elliptictech.com>
> Cc: "David Dillow" <dave@thedillows.org>, "Borislav Petkov" <bp@alien8.de>, linux-kernel@vger.kernel.org,
> netdev@vger.kernel.org
> Sent: Monday, 21 January, 2013 9:37:41 AM
> Subject: Re: IPsec AH use of ahash
> > 
> > I find that 73% of all stats are made up.
> 
> I was only talking about my own experience. I gave no numbers.

That was a joke.  You assumed that because I don't trim whitespace from multi-line comments [among other asinine code style issues] that I'm a bad developer.  Yet what actually happened was a build configuration error in which the file wasn't being compiled fully.

Let it go.

> I was just giving examples of what I use. As those usually apply to
> what
> I do. If your code is affected by any configs, you should compile
> with
> them on and off to make sure you didn't break them. This is a bit
> more
> extensive testing, and not always required. But it does help to do
> so,
> as it becomes embarrassing if your code breaks on a config you didn't
> test.
> 
> That's coming from my own experience too ;-)

Yup, I missed the self-test flag in the menu.  That's full on my bad.  

That said, it should be the opposite [default on] since self-testing should be relatively cheap and easy.  Generally unless it's prohibitive you want as much self-test code-path testing in the default build as possible.  Users who are tight on memory can turn it off if it suits their platform.

> > I actually did resubmit this morning with most of the checkpatch
> > issues fixed.
> 
> Thank you.

Like I said I'm not trying to force everyone else to adopt to how we do things.  I was just airing out a complaint from the point of view of a new submitter.

I still think checkpatch rules are full of sh!t but I know now to run code I submit through it regardless of where the code came from.  :-)

> Your boss micro manages your time that much? And 45 mintes to do
> that?

Strictly speaking I haven't actually tried the code out in the lab yet.  I was hoping that testmgr would run but it hasn't.

Realistically speaking none of the changes I made this morning should have any bearing on the correctness of the code.  I'd be surprised if it failed in the lab.

> > Seriously, no spaces on the trailing edge of multi line comments?
> >  :-/
> 
> Some of checkpatch'es complaints are annoying. I'll grant you that.
> And
> checkpatch is more of a guideline than a strict rule. It's up to the
> maintainer of the code to determine how much checkpatch should be
> enforced.

That's not the impression I got from this weekends exchange.  

> For example, checkpatch complains on code like:
> 
> +       asm volatile (
> +#ifdef CONFIG_X86_64
> +                       "       xchg   %%rbx,%%rsp      \n"
> +#else
> +                       "       xchgl   %%ebx,%%esp     \n"
> +#endif
> +                       "       int3                    \n"
> +                       "       .globl jprobe_return_end\n"
> +                       "       jprobe_return_end:      \n"
> +                       "       nop                     \n"::"b"
> +                       (kcb->jprobe_saved_sp):"memory");
> 
> Because the white space before the '\n' is not needed. But adding
> that
> whitespace makes it easier to read the assembly.

So who gets to decide when/where to deviate from the rules?  
 
> When enforcing checkpatch makes the code less readable, that's when
> it
> should be ignored. But again, that's really up to the maintainer of
> the
> code to decide.

So we divine what the maintainer wants and doesn't want when we submit patches?  I think for me I'm going to follow them literally for now to avoid issues. 

> > Anyways, I did re-submit.  I still have no idea how testmgr works
> > but hopefully someone can pick it up from there.
> 
> Well thank you again. This is the way the kernel community works.
> Just
> state you're not familiar with testmgr, and someone who is should
> check
> it out.

Hopefully :-)

Tom
