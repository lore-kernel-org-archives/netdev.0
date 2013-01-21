From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: IPsec AH use of ahash
Date: Mon, 21 Jan 2013 09:37:41 -0500
Message-ID: <1358779061.21576.19.camel@gandalf.local.home>
References: <1924594099.94729.1358775949651.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Dillow <dave@thedillows.org>, Borislav Petkov <bp@alien8.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1924594099.94729.1358775949651.JavaMail.root@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-01-21 at 08:45 -0500, Tom St Denis wrote:
> 
> ----- Original Message -----
> > From: "Steven Rostedt" <rostedt@goodmis.org>
> > To: "Tom St Denis" <tstdenis@elliptictech.com>
> > Cc: "David Dillow" <dave@thedillows.org>, "Borislav Petkov" <bp@alien8.de>, linux-kernel@vger.kernel.org,
> > netdev@vger.kernel.org
> > Sent: Monday, 21 January, 2013 8:38:54 AM
> > Subject: Re: IPsec AH use of ahash
> 
> > > The missing semi-colon is in fact missing and for that I apologize.
> > >  This btw is the first legitimate gripe with the code thus far.
> > 
> > I've also found that those that have poor coding styles also have
> > more
> > of these "legitimate" problems too. Which is another reason not to
> > accept patches with coding style issues.
> 
> I find that 73% of all stats are made up.

I was only talking about my own experience. I gave no numbers.


> > Did you try different configs? Before submitting my code, I run under
> > 8
> > different configs. SMP, non-SMP, PREEMPT, non PREEMPT, etc. also I
> > run a
> > few random configs before submitting.
> 
> None of course apply to this code [or shouldn't at least].

I was just giving examples of what I use. As those usually apply to what
I do. If your code is affected by any configs, you should compile with
them on and off to make sure you didn't break them. This is a bit more
extensive testing, and not always required. But it does help to do so,
as it becomes embarrassing if your code breaks on a config you didn't
test.

That's coming from my own experience too ;-)

>   
> 
> > Until you can play by the rules, don't bother playing. Feel free to
> > dump
> > code on LKML. Maybe someone that knows how to play the game will take
> > it. But leave your gripes to your managers. No one here, but you,
> > thinks
> > there's a problem with the frame work.
> 
> I actually did resubmit this morning with most of the checkpatch issues fixed. 

Thank you.

> 
> I'll avoid beating the dead horse though I'd like to move forward.
> 
> > > At least the testmgr errors are something I can work on whenever
> > > without setting up a lab so likely that'll be something I can
> > > tackle today actually.
> > 
> > While you're at it. You could spend an extra 5 minutes cleaning up
> > the
> > coding style ;-)
> 
> It actually took me about 45 minutes and about 5 revisions of the patches to clean up all the random coding style gripes from checkpatch.  The only reason I worked on it though is that there were build errors.  That way I can justify it to my boss.

Your boss micro manages your time that much? And 45 mintes to do that?

> 
> Seriously, no spaces on the trailing edge of multi line comments?  :-/

Some of checkpatch'es complaints are annoying. I'll grant you that. And
checkpatch is more of a guideline than a strict rule. It's up to the
maintainer of the code to determine how much checkpatch should be
enforced.

For example, checkpatch complains on code like:

+       asm volatile (
+#ifdef CONFIG_X86_64
+                       "       xchg   %%rbx,%%rsp      \n"
+#else
+                       "       xchgl   %%ebx,%%esp     \n"
+#endif
+                       "       int3                    \n"
+                       "       .globl jprobe_return_end\n"
+                       "       jprobe_return_end:      \n"
+                       "       nop                     \n"::"b"
+                       (kcb->jprobe_saved_sp):"memory");

Because the white space before the '\n' is not needed. But adding that
whitespace makes it easier to read the assembly.

When enforcing checkpatch makes the code less readable, that's when it
should be ignored. But again, that's really up to the maintainer of the
code to decide.

> 
> Anyways, I did re-submit.  I still have no idea how testmgr works but hopefully someone can pick it up from there.

Well thank you again. This is the way the kernel community works. Just
state you're not familiar with testmgr, and someone who is should check
it out.

-- Steve
