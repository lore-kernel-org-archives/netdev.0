From: Andi Kleen <ak@suse.de>
Subject: Re: possible bug in tcp_input.c
Date: 24 Oct 2003 19:57:24 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <p73ptgma58b.fsf@oldwotan.suse.de>
References: <20031024162959.GB11154@louise.pinerecords.com.suse.lists.linux.kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, grof@dragon.cz,
	davem@redhat.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Tomas Szepe <szepe@pinerecords.com>
In-Reply-To: <20031024162959.GB11154@louise.pinerecords.com.suse.lists.linux.kernel>
List-Id: netdev.vger.kernel.org

Tomas Szepe <szepe@pinerecords.com> writes:

> /* tcp_input.c, line 1138 */
> static inline int tcp_head_timedout(struct sock *sk, struct tcp_opt *tp)
> {
>   return tp->packets_out && tcp_skb_timedout(tp, skb_peek(&sk->write_queue));
> }

tp->packets_out > 0 implies that there is at least one packet in the write 
queue (it counts the number of unacked packets in flight, which are kept
in the write queue). When that's not the case something else is wrong.

-Andi
