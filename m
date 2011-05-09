From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [v2 000/115] faster tree-based sysctl implementation
Date: Sun, 08 May 2011 20:11:00 -0700
Message-ID: <m1ei48zhyz.fsf@fess.ebiederm.org>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	"David S . Miller" <davem@davemloft.net>
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
	(Lucian Adrian Grijincu's message of "Mon, 9 May 2011 00:38:12 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lucian Adrian Grijincu <lucian.grijincu@gmail.com> writes:

> Eric also asked for:
> - replacing the per-header list of subdirs with a rbtree.
>   -- Again, lack of time, and this can always be added at a later time
>      to optimize lookup and duplicate checks. At the moment this patch
>      series does not add a complexity regression over the previous
>      implementation, au contraire.

Instead you add a dubious mechanisms, to avoid duplicates checks
because the duplicate checks takes time.

A good internal data structure should have logN duplicate checks
and that should not be cost prohibitive. For maintainability of
the users a good internal data structure removes the need for
special cases, and it actually makes use the sysctl fast.
Your implementation continues to have a O(N^2) cost to use the
sysctl files.

Getting a good internal data structure is the most important part
of a making sysctls fast, and keeping them fast.  Your patchset
fails in that.

So at that level, a great big NAK on the patchset as it currently
exists.


You have made a key observation that we only need better data
structures for the directories and can leave off that work
for the callers.

Thank you for that.

Additionally thank you for splitting up your changes to the
core of sysctl so there is a chance of reviewing those.

With respect to review and merging.  The priorities should be:
1) Figure out what the users really need to do, before we change
   everything so we only need one sweeping pass through the users
   that hopefully simplifies them.

2) Ensure you have a version of the new interfaces ready at the
   start of the patchset, so the sweeping changes can be made
   incrementally.

3) Clean up the users.

4) Make simplifications because you don't have any old users left.

I very much agree that the data structures that sysctl uses today
are far from ideal, and that we can make a lot of headway.

That said I think there is some good work in your patchset and I may
try and cherry pick out the good bits that we can merge now.

Eric
