From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- RCU problem
Date: Tue, 12 Aug 2008 10:29:13 -0700 (PDT)
Message-ID: <151835.36545.qm@web82108.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>
To: Ray Lee <ray-lk@madrabbit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82108.mail.mud.yahoo.com ([209.191.84.221]:41748 "HELO
	web82108.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750779AbYHLR3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 13:29:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> > BRAIN DAMAGE CONTROL:  the problem is only on my hardware, so no one
> > on LKML can play with this hardware directly.  That makes _me_ the weak
> > link.
> 
> Heh. Can I offer a suggestion here? You're trying to do two things at
> once -- finding where the problem is, and also trying to understand
> the problem at the same time. Speaking just for myself, I try to
> either do one of those or the other, but not both at the same time
> :-). Since you bisected it (seems like a good log when I view the
> commit history, but I'm no git expert), let's just work with that.

I having nothing but gratitude for anyone who has any suggestions
whatsoever!

I do _want_ to do both of those things... but you are right that no
one should try to do them both at the same time.  BTW, the bisect data
was from my first post (trying to _find_ the problem) about 8 days ago.
Since that time, I have been _assuming_ I located the cause problem,
and had not thought about it again... until today.

Unfortunately, this kernel stuff can get very deep.  Just finding the
commit, where "before" works and "after" does not, doesn't necessarily
seem to mean that the commit is the problem.  It could also mean that
the problem was already present, and the commit exposed it.  So for me,
or anyone, to be going over that commit with a fine-toothed comb could
either be exactly what's needed or a complete waste of time!


> > 1.  Can someone comment on whether I correctly identified the commit #
> > causing the issue for me.  Here is the 'git bisect' data from my first
> > post:
> >
> > 2.6.25, good
> > 2.6.26-rc4, bad
> > 10c993a6b5418cb1026775765ba4c70ffb70853d, bad
[...]
> > 3def3d6ddf43dbe20c00c3cbc38dfacc8586998f, bad
> > 700efc1b9f6afe34caae231b87d129ad8ffb559f, good
> >
> > I concluded that 3def3d... was causing the problem for me, but I didn't
> > actually pipe or redirect the output message from 'git bisect' when it
> > stated that.  Does that conclusion look OK?
> 
> Git should have printed out "is first bad commit" Did you see
> that? If not, you stopped the process too soon. Viewing the history
> with gitk, though, it seems you fingered the right commit. Which leads
> to the next step...

It _did_ print that message.  My meaning here was that I did not have
the presence of mind to record that output in any way.  I have a memory
that the output indicated "3d...", but that could be a false memory.
(Thus the reference to brain damage.)

What I _was_ careful to record was the list posted above.  I used a
text editor to take notes after each stage of the bisecting process,
but I failed to actually take that last note on the finally output.  That
list documents all of iterations in the process, and I concluded that it
was identifying commit #3def..., and I just wanted to make sure everyone
agreed with that.


> > 2.  I have not tried different versions of gcc.
> 
> Which is not this :-).

  Just making sure... but thanks!


> > 3.  I keep wanting to play with source code,
> 
> Or this :-).

I thought so....

Since this _feels_ like my problem alone, then it _feels_ like I
should have to be the one to fix it.  I hate having to throw my arms
up and admit I am unable to do something about it....


> Can you try reverting that commit against the top of the latest tree,
> and see if the revert applies correctly? If it does, compile and boot
> and see if it works.

OK, I can give it a try.  I probably would have tried it already but I 
noticed that the file(s) touched by the commit had been merged with one
or more other files in the meantime, so I decided to leave it alone.  But
now that I think about it, what is the worst that can happen?  The kernel
will fail to build?  It will build, but it won't run?  That's happening
already, so I have nothing to lose.

Thanks!


> If it does, it'll be Yinghai's job to figure out
> what went wrong, not yours (unless you're a real gluton for
> punishment, and happen to know what was going on in Yinghai's head
> when he decided that it was safe to make those changes).

Well, it's his job only if his commit broke something.

Is 2.6.2[67] broken on your machine?  Or on anyone's machine on LKML?
These kernels even work on one of my machines!  So it's not clear that
Yinghai's commit is to blame:  maybe it is, maybe it isn't.  All that
we know is that commit triggered the problem, and we don't even know
whether the problem will affect a lot of hardware or just mine!

Anyway, I think you were really just trying to be nice, and I thank you
for it.  I do feel marginally better.  ;)

I'll really feel better if the reverting experiment works.


Thanks,
Dave W.
