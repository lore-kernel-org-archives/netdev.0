From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] tiny af_packet.c cleanup
Date: Sat, 13 Sep 2003 11:03:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030913110353.B23840@electric-eye.fr.zoreil.com>
References: <20030913055033.GB94744@gaz.sfgoth.com> <20030913093559.A23840@electric-eye.fr.zoreil.com> <20030913080252.GE94744@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
Content-Disposition: inline
In-Reply-To: <20030913080252.GE94744@gaz.sfgoth.com>; from mitch@sfgoth.com on Sat, Sep 13, 2003 at 01:02:52AM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mitchell Blank Jr <mitch@sfgoth.com> :
[...]
> I thought that without the comment someone might think that the second
> "if()" wasn't needed (since we had just checked the same value against
> NULL a few lines up)

Ok, I completely missed the intent.

Actually packet_rcv() is run in a BH context and doesn't race with
SO_{ATTACH/DETACH}_FILTER from sock_setsockopt() which does the
appropriate BH locking (spin_lock_bh(&sk->sk_lock.slock) in
net/core/sock.c::sock_setsockopt and in net/core/filter.c::sk_attach_filter).
packet_rcv() doesn't race with BH either due to the bh_lock_sock (a spin_lock
in disguise) you quoted.

That being said, I don't see how such an explanation could fit in a short,
inlined comment. :o)

--
Ueimor
