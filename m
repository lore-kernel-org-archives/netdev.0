From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Thu, 10 Mar 2011 16:51:34 -0800
Message-ID: <AANLkTimAPqTYT_j6t3cT32WfD6cQPySG0tnQVhC8Z=NO@mail.gmail.com>
References: <AANLkTimnHtVS=SFopgyjAAQDW8bXDKDXf+YvEtPdpPsA@mail.gmail.com>
 <20110310.155556.48513201.davem@davemloft.net> <AANLkTik3AyFTNoytebmOOZ=JSFMkt0bw7au-CSncUHJu@mail.gmail.com>
 <20110310.163434.260095615.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110310.163434.260095615.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2011 at 4:34 PM, David Miller <davem@davemloft.net> wrote:
>
> So, this is like a cherry-pick of sorts that doesn't create new commits?
> It just makes the merge commit, and that's where I explain why I need this
> particular change in my tree.
>
> Right?

No, it's really just a perfectly regular merge. It's just that instead
of "merge whatever random state that Linus' tree happened to be in, in
order to get that one commit I wanted", it instead does a "merge the
_particular_ history that led up to the one commit I want".

So it's still a back-merge, and in that sense it is technically
absolutely no different from your "merge master" thing. You'll be
merging not just that one commit, but all the parents of the commit
too. So it's not like a cherry-pick, that literally just takes that
one single commit. You do get history, the same way you get with any
merge.

The reason I would suggest doing the "pick explicitly" is just that it
- at least to me - makes it much clearer *what* you actually wanted to
do. It's really the explicitness of "I need that particular commit" vs
"I just want to get whatever Linus has, because he ended up merging a
thing I wanted".

Put another way, I want merging to be something people think about,
and have a clear reason for. Now, for a regular upstream merge, that
"clear reason" is so obvious that we never even discuss it: most of
the merges in the kernel tree have a very simple reason, that simply
goes as "submaintainer asked for his tree to be merged". That's such
an obvious thing that we don't write it out - and it's why I
(stupidly) thought that "git merge" and "git pull" can just generate
the merge messages automatically.

But in other cases, there are less obvious reasons for why a merge
happens, and it's usually a case of a back-merge (ie a submaintainer
merging from upstream, rather than upstream merging from a
submaintainer). Now, there are various good reasons for those kinds of
merges too, and the automated git messages are all usually totally
useless for that case.

The reasons can be any of:

 - "I don't want to get too far away from upstream". This is very
understandable, but I have asked people to please _not_ merge "random
trees of the day". Please use major releases for this (or, if worst
comes to worst, -rc releases) rather than just do something else.

 - "I need the functionality that went upstream, and I don't want to
duplicate it". This was your case, and again, it's entirely
understandable. It's just that I think it should be explained, so that
people who see the merge also see _why_ the merge was done. And again,
I don't like seeing "merge random tree of the day". There should
really be some explicit thought about _why_ the merge is needed, and
if you merge a tree because you need a particular state, then I think
you should merge _that_ tree, not just "whatever Linus happened to
have right then".

I basically think "merge random tree" is _always_ wrong.

And I do admit that it's a big design mistake in git to not force
people to think about things, and to make it much too easy to generate
useless merge messages. As mentioned, that whole automatic merge
message thing makes a _lot_ more sense to upstream than it does to
downstream: when you're merging from a submaintainer, the implicit
fact that downstream _asked_ you to merge is what makes the automatic
message actually worth something.

Put another way: the same way I think it's wrong when you merge some
random tree from me, I think it would be very wrong for me to merge
your random tree of the day. That would be crazy - who knows what the
heck you have in your tree, and unless you ask me to merge, I should
just assume that it's broken. You may be in the middle of some
development thing, and your tree may be totally broken. I shouldn't
pull it.

The same is true the other way around. Sure, especially late in the
-rc cycle, you can hopefully assume that my tree isn't crap, but even
so, I would really like people to think about _what_ they are merging.
And making it explicit is a good thing, I think.

                                 Linus
