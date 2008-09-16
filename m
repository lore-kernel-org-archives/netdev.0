From: Theodore Tso <tytso@mit.edu>
Subject: Re: [git patches] net driver fixes
Date: Tue, 16 Sep 2008 09:54:08 -0400
Message-ID: <20080916135408.GB13388@mit.edu>
References: <20080916104811.GC7397@cs181140183.pp.htv.fi> <20080916114305.GB10965@ff.dom.local> <20080916121528.GD7397@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755217AbYIPNyh@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080916121528.GD7397@cs181140183.pp.htv.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 16, 2008 at 03:15:28PM +0300, Adrian Bunk wrote:
> 
> More seriously, there's a difference between Linus' "another random 
> improvement" and an "is even suitable for -stable".
> 
> I'm not reading Linus' (Cc'ed) statement the way that a patch that is 
> appropriate for 2.6.27.1 is not appropriate for -rc now.

Well, remember that patches that get published for -stable do have to
go through an extra review process.  It's not true that any "obviously
correct" bug fix gets automatically published in -stable.  Sometimes
bug fixes do get rejected for -stable because they are too risky, or
require more time for testing in the -rc series before they are deemed
suitable for -stable.

Looking at 2.6.26, there is currently about 195 patches queued up,
which is certainly not all of the bugs fixed during the 2.6.27
development cycle.  Some of it is that some developers aren't as
aggressive about nominating patches for backporting to 2.6.26, and
some of it is that only the really *important* bugs get this treatment.

But, I bet that if there was a major embarassing problem where someone
abused the process by submitting an "obviously correct" patch that
ended up breaking things for a others, the end result would be that
the -stable team would start cracking down and start using more strict
criteria about what would be considered allowable for publishing in
-stable.

I'll remind people that the original rule was that new features were
only allowed in -rc1, and bug fixes in -rc1 and -rc2.  But because
that got abused, Linus is now saying that only regression bug fixes
are allowed post -rc1.  My belief is that part of the reason for this
is that Linus is a self-described soft touch, and by stating a
draconian rule, he's hoping that subsystem maintainers like David will
lay done the law, and prevent the really serious abuses (where people
starting submitting "obvious bug fixes" in -rc5 and -rc6 that caused
regressions which in turn ends up extending the release cycle).

If it's a really important bug, and it affects a huge number of users,
or it's really bad security bug, the reality is that exceptions will
be made to the rules.  But exceptions need to remain exceptions for
extraordinary situations, not everyday occurrences.  And of course, if
the bug does affect a huge number of users, someone should be asking
the question why it wasn't detected sooner, say before the last merge
window --- and to ask the question how many users is this bug really
going to affect anyway?

At least, that's my take on things,

						- Ted
