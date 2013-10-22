From: Dave Taht <dave.taht@bufferbloat.net>
Subject: Re: [PATCH 1/2] fq_codel: keep dropped statistic around
Date: Mon, 21 Oct 2013 18:43:10 -0700
Message-ID: <20131022014310.GA5076@lists.bufferbloat.net>
References: <1382404797-17239-1-git-send-email-dave.taht@bufferbloat.net>
	<1382404797-17239-2-git-send-email-dave.taht@bufferbloat.net>
	<CAL4Wiio0YThCbT8j92HVn1CmmdvKD=GT30ZtMf=ZvmAj+ZM7Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, codel@lists.bufferbloat.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
Content-Disposition: inline
In-Reply-To: <CAL4Wiio0YThCbT8j92HVn1CmmdvKD=GT30ZtMf=ZvmAj+ZM7Yg@mail.gmail.com>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

On Mon, Oct 21, 2013 at 06:27:11PM -0700, Eric Dumazet wrote:
> On Oct 21, 2013 6:20 PM, "Dave Taht" <dave.taht@bufferbloat.net> wrote:
> >
> > Having more accurate dropped information in this qdisc is useful.
> >
> > Signed-off-by: Dave Taht <dave.taht@bufferbloat.net>
> > ---
> >  net/sched/sch_fq_codel.c |    1 -
> >  1 file changed, 1 deletion(-)
> >
> > diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> > index 5578628..437bc95 100644
> > --- a/net/sched/sch_fq_codel.c
> > +++ b/net/sched/sch_fq_codel.c
> > @@ -193,7 +193,6 @@ static int fq_codel_enqueue(struct sk_buff *skb,
> struct Qdisc *sch)
> >                 list_add_tail(&flow->flowchain, &q->new_flows);
> >                 q->new_flow_count++;
> >                 flow->deficit = q->quantum;
> > -               flow->dropped = 0;
> >         }
> >         if (++sch->q.qlen <= sch->limit)
> >                 return NET_XMIT_SUCCESS;
> > --
> > 1.7.9.5
> I am travelling to Edinburgh, so will be short.

Wish I could have made it.

> Since fqcodel recycles a slot, we need to clear this counter. 

I prefer to think of it as a per "slot dropped counter" and to
have it retain the total number of drops in that slot since
qdisc initialization.

> We do no know
> if slot is reused by previous flow or a new flow hashing to same bucket.

There could also in this case be several flows hashing to the same bucket
and dropping packets. 

In most cases with the current zero-ing of "drop", polling "tc -s class" 
yields an unrevealing drop statistic of "0" for many workloads against
multiple streams at lower bandwidths.

with it not getting zeroed, as per this patch, clear patterns show over 
many seconds as queues empty, get filled by bursts, and get drops. 

This patch has been in openwrt and cerowrt since feburary.
