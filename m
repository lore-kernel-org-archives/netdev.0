From: Tomas Szepe <szepe@pinerecords.com>
Subject: Re: possible bug in tcp_input.c
Date: Tue, 18 Nov 2003 14:58:05 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118135805.GA9705@louise.pinerecords.com>
References: <20031024162959.GB11154@louise.pinerecords.com.suse.lists.linux.kernel> <p73ptgma58b.fsf@oldwotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, grof@dragon.cz,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <p73ptgma58b.fsf@oldwotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Oct-24 2003, Fri, 19:57 +0200
Andi Kleen <ak@suse.de> wrote:

> > /* tcp_input.c, line 1138 */
> > static inline int tcp_head_timedout(struct sock *sk, struct tcp_opt *tp)
> > {
> >   return tp->packets_out && tcp_skb_timedout(tp, skb_peek(&sk->write_queue));
> > }
> 
> tp->packets_out > 0 implies that there is at least one packet in the write 
> queue (it counts the number of unacked packets in flight, which are kept
> in the write queue). When that's not the case something else is wrong.

Yes, that's exactly what davem said.  The corruption is happening somewhere
in netsched/imq code that's not even part of the official kernel tree (and
I'm told there's nobody to maintain the patch at present).

Thanks,
-- 
Tomas Szepe <szepe@pinerecords.com>

P.S.  I can post the patchset we've been using on the crashing machines
in case someone's interested, it's reasonably short:

      9101 Jul  6 11:48 bridge-nf-0.0.7-against-2.4.22pre3.diff.gz
      4123 Jul  6 11:14 imq-2.4.22pre3-1.diff.gz
      1883 Jul  6 12:01 imq-nf-20030625-2.4.22pre3.diff.gz
