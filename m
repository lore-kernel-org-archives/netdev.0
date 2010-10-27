From: Bill Fink <billfink@mindspring.com>
Subject: Re: tbf/htb qdisc limitations
Date: Wed, 27 Oct 2010 00:51:43 -0400
Message-ID: <20101027005143.bfa8fbfd.billfink@mindspring.com>
References: <20101014085005.GA8349@ff.dom.local>
	<20101015023749.f085006b.billfink@mindspring.com>
	<1287125059.2659.1812.camel@edumazet-laptop>
	<20101015173746.12c7c40a.billfink@mindspring.com>
	<20101015220535.GA1997@del.dom.local>
	<20101016005106.35e4cc8d.billfink@mindspring.com>
	<20101016205824.GA2113@del.dom.local>
	<20101016212434.72ae5250.billfink@mindspring.com>
	<20101017203618.GA1889@del.dom.local>
	<20101019033724.0bffbe88.billfink@mindspring.com>
	<20101020110612.GA18315@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:59943 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751132Ab0J0Evo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 00:51:44 -0400
In-Reply-To: <20101020110612.GA18315@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Oct 2010, Jarek Poplawski wrote:

> On Tue, Oct 19, 2010 at 03:37:24AM -0400, Bill Fink wrote:
> > On Sun, 17 Oct 2010, Jarek Poplawski wrote:
> > 
> > > On Sat, Oct 16, 2010 at 09:24:34PM -0400, Bill Fink wrote:
> > > > On Sat, 16 Oct 2010, Jarek Poplawski wrote:
> > > ...
> > > > > http://code.google.com/p/pspacer/wiki/HTBon10GbE
> > > > >  
> > > > > If it doesn't help reconsider hfsc.
> > > > 
> > > > Thanks for the link.  From his results, it appears you can
> > > > get better accuracy by keeping TSO/GSO enabled and upping
> > > > the tc mtu parameter to 64000.  I will have to try that out.
> > > 
> > > Sure, but you have to remember that scheduler doesn't know real packet
> > > sizes and rate tables are less accurate especially for smaller packets,
> > > so it depends on conditions.
> > 
> > On my testing on the real data path, TSO/GSO enabled did seem
> > to give more accurate results for a single stream.  But when
> > I tried multiple 10-GigE paths simultaneously, each with a
> > single stream across it, non-TSO/GSO seemed to fare better
> > overall.
> 
> Btw, if you find time I would be interested in checking an opposite
> concept of lower than real mtu (256) to use rate tables different way
> (other tbf parameters without change). The patch below is needed for
> this to work.

Sorry.  I'm totally swamped at work currently and won't be able
to investigate that.

						-Bill



> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> index 641a30d..9ac3460 100644
> --- a/net/sched/sch_tbf.c
> +++ b/net/sched/sch_tbf.c
> @@ -123,9 +123,6 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
>  	struct tbf_sched_data *q = qdisc_priv(sch);
>  	int ret;
>  
> -	if (qdisc_pkt_len(skb) > q->max_size)
> -		return qdisc_reshape_fail(skb, sch);
> -
>  	ret = qdisc_enqueue(skb, q->qdisc);
>  	if (ret != NET_XMIT_SUCCESS) {
>  		if (net_xmit_drop_count(ret))
