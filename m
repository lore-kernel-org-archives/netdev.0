From: jamal <hadi@cyberus.ca>
Subject: Re: Linux SMP on 2.4.18-3
Date: Mon, 28 Oct 2002 07:47:44 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210280741020.9849-100000@shell.cyberus.ca>
References: <Pine.LNX.4.33L0.0210270117050.10547-100000@fast2.cs.caltech.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Cheng Jin <chengjin@cs.caltech.edu>
In-Reply-To: <Pine.LNX.4.33L0.0210270117050.10547-100000@fast2.cs.caltech.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



The IP network stack in linux is totaly reentrant. You could have a
packet on _each_ processor in SMP concurently executing the same code. If
you add anything, you need to take this into account.
In non-NAPI based NICs such as yours, you could have reordering within
the system (this is described in the NAPI paper). Either get it NAPIfied
or get yourself a NAPI capable NIC such as tg3 based, e1000, Dlink gige
etc.

cheers,
jamal

On Sun, 27 Oct 2002, Cheng Jin wrote:

> Hi,
>
> Please excuse me for asking questions on a rather old kernel.  We decided
> to do kernel modificatios against 2.4.18-3 so we can't back it out now.
>
> On the SMP test machine we have at the lab (Dual 2.4 Ghz Xeons with one
> SysKonnect Gigabit Ethernet card, SuperMicro P4DP6 MB), I observed TCP
> functions being called simultaneously by both processors.  What I did was
> to simply increment a counter (init to zero) and check whether it is one
> in the functions under suspicion.  Sure enough, I see a lot of messages
> printed out saying it is two.  Admittedly, my counter var is not protected
> either, but seeing it becoming 2 is proof enough that the functions are
> entered simultaneously (yes I decrement the counter before functions
> return).
>
> I looked at the code fairly extensively, and I didn't see any lock for
> these functions, tcp_send_skb, tcp_push_one, update_send_head, where
> packets_out gets incremented.  The problem I was having was that
> tp->packets_out got out of sync with the number of unacked packets on the
> sk->write_queue.
>
> I would like to confirm with people that are involved with kernel
> developement that what I observed was indeed correct.
>
> Thanks,
>
> Cheng
>
> Lab # 626 395 8820
>
>
