From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [PATCH] tiny af_packet.c cleanup
Date: Sat, 13 Sep 2003 13:15:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030913201559.GI94744@gaz.sfgoth.com>
References: <20030913055033.GB94744@gaz.sfgoth.com> <20030913093559.A23840@electric-eye.fr.zoreil.com> <20030913080252.GE94744@gaz.sfgoth.com> <20030913110353.B23840@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20030913110353.B23840@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Actually packet_rcv() is run in a BH context and doesn't race with
> SO_{ATTACH/DETACH}_FILTER from sock_setsockopt() which does the
> appropriate BH locking (spin_lock_bh(&sk->sk_lock.slock) in
> net/core/sock.c::sock_setsockopt and in net/core/filter.c::sk_attach_filter).
> packet_rcv() doesn't race with BH either due to the bh_lock_sock (a spin_lock
> in disguise) you quoted.

I don't understand what you're saying - are you saying that the locking
isn't needed?  Or just the recheck isn't needed?  It sounds like if we're
only avoiding the race because of the bh_lock_sock() then we do need to
recheck, right?

Could you do a patch for what you think it should look like?  You obviously
understand the locking issues here better than I.

-Mitch
