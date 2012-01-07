From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Fri, 6 Jan 2012 18:24:31 -0800
Message-ID: <CA+55aFwsTfGRkKASqa_LFQwGZnYyTdVTzb4MG=2Ywv+bG1E1Qw@mail.gmail.com>
References: <CA+55aFyk6QJib8UCtK_gWzidr8Ti1utJgHg359fkq=+GY8hbnw@mail.gmail.com>
 <20120106.175028.1076280359661712542.davem@davemloft.net> <CA+55aFwbykuZ30i2qrdAbX=PzRC5jtOYuAk8s8j47OP7qDSM8g@mail.gmail.com>
 <20120106.180745.694506225640408539.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120106.180745.694506225640408539.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 6, 2012 at 6:07 PM, David Miller <davem@davemloft.net> wrote:
>
> Ok, we can take away those default Kconfig tags for the UDP and AF_UNIX
> bits, no problem.

I'd really like the basic rule to be that all new features start out
as 'default n'. Sure, some day they may be the common case, and then
we can add the 'default y' line, but we should wait for that to
happen, rather than try to push it. Because if the feature isn't so
compelling that distributions don't start enabling the *use* of it,
then we should acknowledge that too.

The one exception is that when an *old* feature is hidden behind a
*new* config option - if it used to be compiled in by default (even if
that was for a bad reason), we should still default to compiling it
in. So when you did the network driver Kconfig layout change, making
those vendor choices default to 'y' (in order to see the old drivers
that still existed under those choices) was the right thing to do, for
example. Otherwise it's just too easy for people to be confused and
not realize that they need to do something special in order to get
their old supported behavior.

And no, we have not always followed these rules. Too many new "cool
features" don't get a config option at all, and just bloat the kernel
whether they are used or not. And people don't even notice, because
then you don't even get the heads-up from trying to reconfigure the
kernel - the feature is just silently enabled without questions.
Sometimes that's the right thing to do ("avoid the pain of new config
options") but quite often it's just people being lazy. Oh well.

                       Linus
