From: Cheng Jin <chengjin@cs.caltech.edu>
Subject: Linux SMP on 2.4.18-3
Date: Sun, 27 Oct 2002 01:27:47 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33L0.0210270117050.10547-100000@fast2.cs.caltech.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Please excuse me for asking questions on a rather old kernel.  We decided
to do kernel modificatios against 2.4.18-3 so we can't back it out now.

On the SMP test machine we have at the lab (Dual 2.4 Ghz Xeons with one
SysKonnect Gigabit Ethernet card, SuperMicro P4DP6 MB), I observed TCP
functions being called simultaneously by both processors.  What I did was
to simply increment a counter (init to zero) and check whether it is one
in the functions under suspicion.  Sure enough, I see a lot of messages
printed out saying it is two.  Admittedly, my counter var is not protected
either, but seeing it becoming 2 is proof enough that the functions are
entered simultaneously (yes I decrement the counter before functions
return).

I looked at the code fairly extensively, and I didn't see any lock for
these functions, tcp_send_skb, tcp_push_one, update_send_head, where
packets_out gets incremented.  The problem I was having was that
tp->packets_out got out of sync with the number of unacked packets on the
sk->write_queue.

I would like to confirm with people that are involved with kernel
developement that what I observed was indeed correct.

Thanks,

Cheng

Lab # 626 395 8820
