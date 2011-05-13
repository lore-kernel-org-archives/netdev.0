From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: AAARGH bisection is hard (Re: [2.6.39 regression] X locks up hard
 right after logging in)
Date: Fri, 13 May 2011 09:11:31 -0700
Message-ID: <BANLkTimE2GkkhcFZtNrYZASWp0LDhUx=GQ@mail.gmail.com>
References: <BANLkTi=kb_m-CfrpnD8qQTVYLGaDdgy_tg@mail.gmail.com>
 <BANLkTikMeyRTOB9q4PEAYWnZRZfk3wg=kQ@mail.gmail.com> <BANLkTi=dL+KyQ3Bm58_Uj4LP9WSpbzAfJA@mail.gmail.com>
 <BANLkTi=NdVUUZ=_bACzyeMGS3JWs0EMbWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Christian Couder <christian.couder@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	git@vger.kernel.org, Shuang He <shuang.he@intel.com>
To: Andrew Lutomirski <luto@mit.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTi=NdVUUZ=_bACzyeMGS3JWs0EMbWA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 13, 2011 at 7:56 AM, Andrew Lutomirski <luto@mit.edu> wrote:
>
> So what I really want is a fancy version of git bisect that makes no
> assumptions about the relationship of good and bad commits in the
> graph and just finds me a commit that is bad but for which all parents
> are good or vice versa.

Ehh. That's the "non-fancy" way of testing, I'm afraid: if you cannot
make assumption about the relationship between good and bad commits,
then you have to test _every_ commit.

So yes, bisection has its problems. But they really do come from the
fact that it's very efficient. When you have (on average) about ten
thousand commits between releases, you have to make assumptions about
the relationships. But once you do that, the efficiency also results
in a certain fragility.

Think of it as a compression method: it generates the smallest
possible set of test points for you. But it's a "lossy" compression -
you don't test everything. And it's extreme: it boils down 10k commit
events to about 13 bisection events. If anything goes wrong (like the
bug not being entirely repeatable, or the bug comes and goes), it will
give the wrong answer.

The good news is that _usually_ it works really well. And when the
choice is between "works really well for 10k commits but can have
problems" and "you need to test all 10k commits", the "can have
problems" part turns out to be a pretty small downside ;)

                                Linus
