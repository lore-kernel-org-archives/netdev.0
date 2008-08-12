From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- RCU problem
Date: Tue, 12 Aug 2008 09:03:10 -0700
Message-ID: <2c0942db0808120903i3680dab2k920eb952bf806ab1@mail.gmail.com>
References: <962464.9576.qm@web82108.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"Peter Zijlstra" <peterz@infradead.org>,
	"Yinghai Lu" <yhlu.kernel@gmail.com>,
	"Ingo Molnar" <mingo@elte.hu>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>
To: "David Witbrodt" <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:63458 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbYHLQDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 12:03:11 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2851617rvb.1
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 09:03:10 -0700 (PDT)
In-Reply-To: <962464.9576.qm@web82108.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 8:17 AM, David Witbrodt <dawitbro@sbcglobal.net> wrote:
> BRAIN DAMAGE CONTROL:  the problem is only on my hardware, so no one
> on LKML can play with this hardware directly.  That makes _me_ the weak
> link.

Heh. Can I offer a suggestion here? You're trying to do two things at
once -- finding where the problem is, and also trying to understand
the problem at the same time. Speaking just for myself, I try to
either do one of those or the other, but not both at the same time
:-). Since you bisected it (seems like a good log when I view the
commit history, but I'm no git expert), let's just work with that.

> 1.  Can someone comment on whether I correctly identified the commit #
> causing the issue for me.  Here is the 'git bisect' data from my first
> post:
>
> 2.6.25, good
> 2.6.26-rc4, bad
> 10c993a6b5418cb1026775765ba4c70ffb70853d, bad
> 334d094504c2fe1c44211ecb49146ae6bca8c321, bad
> eddeb0e2d863e3941d8768e70cb50c6120e61fa0, bad
> 77ad386e596c6b0930cc2e09e3cce485e3ee7f72, bad
> ede1389f8ab4f3a1343e567133fa9720a054a3aa, bad
> c048fdfe6178e082be918d4062c86d9764979112, bad
> f73920cd63d316008738427a0df2caab6cc88ad7, bad
> 04aaa7ba096c707a8df337b29303f1a5a65f0462, good
> 8fa6878ffc6366f490e99a1ab31127fb599657c9, good
> 1180e01de50c0c7683c6648251f32957bc2d7850, good
> 1e934dda0c77c8ad13fdda02074f2cfcea118a56, bad
> 322850af8d93735f67b8ebf84bb1350639be3f34, good
> 3def3d6ddf43dbe20c00c3cbc38dfacc8586998f, bad
> 700efc1b9f6afe34caae231b87d129ad8ffb559f, good
>
> I concluded that 3def3d... was causing the problem for me, but I didn't
> actually pipe or redirect the output message from 'git bisect' when it
> stated that.  Does that conclusion look OK?

Git should have printed out "<SHA1> is first bad commit" Did you see
that? If not, you stopped the process too soon. Viewing the history
with gitk, though, it seems you fingered the right commit. Which leads
to the next step...

> 2.  I have not tried different versions of gcc.

Which is not this :-).

> 3.  I keep wanting to play with source code,

Or this :-).

Can you try reverting that commit against the top of the latest tree,
and see if the revert applies correctly? If it does, compile and boot
and see if it works. If it does, it'll be Yinghai's job to figure out
what went wrong, not yours (unless you're a real gluton for
punishment, and happen to know what was going on in Yinghai's head
when he decided that it was safe to make those changes).
