From: Nicolai Stange <nicstange@gmail.com>
Subject: Re: Linux 4.4-rc4 regression, bisected to "net: fix sock_wake_async() rcu protection"
Date: Wed, 30 Dec 2015 12:32:07 +0100
Message-ID: <8760zgnpe0.fsf@gmail.com>
References: <CALCETrUHFDdfPymKfD2TJHL6w-C5dc675xuJfk=c=-twsPZqqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Andy Lutomirski <luto@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrUHFDdfPymKfD2TJHL6w-C5dc675xuJfk=c=-twsPZqqA@mail.gmail.com>
	(Andy Lutomirski's message of "Wed, 30 Dec 2015 03:18:11 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Lutomirski <luto@kernel.org> writes:

> On recent v4.4-rc releases, I can't run emacs.  No, really, running
> "emacs" in a GNOME 3 session makes gnome-shell think that emacs is
> running, but no window is drawn, and the overall system UI is a bit
> weird when the invisible emacs window is focused.
>
> This is 100% reproducible.
>
> There might be other symptoms involving gdb malfunctioning, but those
> are, at best, sporadic.  The emacs failure is entirely reliable.  I
> have no idea what the underlying failure mode is, but failure to wake
> a socket waiter seems plausible,  I also have no idea why oocalc,
> gimp, vim, gedit, firefox, etc aren't affected.
>
> A somewhat unorthodox "git bisect" run blames:
>
> commit ceb5d58b217098a657f3850b7a2640f995032e62
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Sun Nov 29 20:03:11 2015 -0800
>
>     net: fix sock_wake_async() rcu protection
>
> I've confirmed that v4.4-rc7 with that patch reverted works fine.
>
> Since the offending commit was apparently a security fix, simply
> reverting it might not be the best idea.

Please have a look at https://lkml.kernel.org/g/87ege73bma.fsf@gmail.com

I ran into the same issue and this one fixes it for me.

Best,

Nicolai
