From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 25 Oct 2011 13:46:11 +0200
Message-ID: <CA+55aFw1GVvszqoC_f0RAvG5t1xj0CSYLhLU=y0gQ+_54Gsomw@mail.gmail.com>
References: <20111025.063206.2273357152859701628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, Greg KH <gregkh@suse.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Mikulas Patocka <mpatocka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111025.063206.2273357152859701628.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 25, 2011 at 12:32 PM, David Miller <davem@davemloft.net> wr=
ote:
>
> I have to say I was really impressed with GIT's rename detection. =A0=
=46or
> example, when I'd pull bug fixes from the 'net' tree into this
> 'net-next' tree, GIT would figure it out and cleanly merge in the
> fixes even though the file names were completely different.

Sadly, it doesn't work with files that aren't moved, but are split
into lots of files. So I got a conflict on the drivers/net/Kconfig
file due to the file being moved to tons of different locations. But
the change was pretty trivial, so I think I got that trivially right
too.

> I'll also note that I had to bump GIT's diff.renamelimit to about 100=
0
> to generate this pull request.

Yeah. You can probably just set it to zero to disable the limiting
entirely. The reason for the rename limit is for crazy use cases on
smaller machines than you'll probably ever use. So the git default
values tend to try to be safe for people who have smaller machines.

> I think that, without the driver renames, this is actually a smaller
> networking pull request than usual for the merge window.

This had an annoying conflict with some of the driver base changes. It
was made doubly annoying by the fact that Greg seems to use some
seriously bad drugs, and creates totally crap commit messages that are
just annoying when you have to look at them because there's some
conflict.

Greg - please fix your crazy tools. Look at this:

   git log fs/sysfs/dir.c

and tell me why the f*&% you have commit messages like this:

  commit 4f72c0cab40536a0be501d85ea4918467ab82ad5
  Author: Mikulas Patocka <mpatocka@redhat.com>
  Date:   Mon Jul 25 17:55:57 2011 -0400

      sysfs: use rb-tree for name lookups

      sysfs: use rb-tree for name lookups

      Use red-black tree for name lookups.

      Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
      Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

and there's a *lot* of them. That duplication of the header line is
useless. It is *doubly* useless to then have a "body" of the commit
that just says the same thing *again*. Christ!

EVERY SINGLE COMMIT from Mikulas has that problem. WHY?

So stop duplicating the header line! And make the body of the commit
actually tell us something *useful*.

Anyway, after that rant about really bad practices, let me say that I
did fix up the conflict and I think it's right. But I won't guarantee
it, so please check the changes to fs/sysfs/dir.c.

I added Mikulas, Greg and Eric Biederman to the email, because those
three people seem to be the ones that caused the conflicts in that
file. Please do check out my conflict resolution.

                   Linus
