From: Zdenek Radouch <zdenek@rcn.com>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Sun, 06 Mar 2005 14:48:31 -0500
Message-ID: <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
References: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net> <20050306173145.GQ31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Martin Mares <mj@ucw.cz>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050306173145.GQ31837@postel.suug.ch>
References: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


OK, I think I am getting the picture.

1) looks like what I need may be possible, at least as far as
    some kernels are concerned.  It's not clear that 2.4.25 will work.

2) I only have to perform close to magic in locating the "right"
    tools that happen to work on a "right" kernel release.

3) Clearly the route processing is in flux, at least within the
    releases I am dealing with, so I need to be careful interpreting
    what I see, and I should avoid making any inferences.

There is no doubt that the 127.x net is treated in a special
way.  If I have to believe what I just learned, then the 127
routes are in a "local" table, a table on which the "route"
utility by definition does not operate!  On the 2.4.25 machine
I cannot get any of the "ip" commands to execute without
an error:

  $ ip route del 127.0.0.1 dev lo table local
  ip: either "to" is duplicate, or "table" is a garbage.

Since there was no "to" on the command line I suspect
the busybox crap to be doing something very bad.
I'll look at that.

To summarize, it appears that I can subnet the 127 net
by appropriately manipulating one or two kernel routing tables,
if I can find the right tools to do that.  If the tools don't work, then
getting the tools to work would be the necessary modifications
I would have to make on my machines to get the job done.

I'd like to thank everyone for their help.

Regards,
-Zdenek
