From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH][NET_SCHED] sch_prio: class statistics printing enabled
Date: Wed, 31 Jan 2007 16:17:21 +0100
Message-ID: <20070131151721.GA3811@ff.dom.local>
References: <20070131075348.GA1857@ff.dom.local> <45C09E0B.6020107@trash.net> <20070131143522.GB3521@ff.dom.local> <45C0A9A5.4080607@trash.net> <20070131150102.GA3643@ff.dom.local> <45C0B05D.3020101@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:60023 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964806AbXAaPOl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 10:14:41 -0500
Content-Disposition: inline
In-Reply-To: <45C0B05D.3020101@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 31, 2007 at 04:06:05PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> >>From sch_api.c:
> > 
> > 
> >>       if (cl_ops->dump && cl_ops->dump(q, cl, skb, tcm) < 0)
> >>               goto rtattr_failure;
> >>
> >>       if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
> >>                       TCA_XSTATS, q->stats_lock, &d) < 0)
> >>               goto rtattr_failure;
> >>
> >>       if (cl_ops->dump_stats && cl_ops->dump_stats(q, cl, &d) < 0)
> >>               goto rtattr_failure;
> > 
> > 
> > I can't see any difference between calling ->dump and
> > ->dump_stats? Of course we may forsee this error should
> > jump over cl_ops...
> 
> 
> Why should there be a difference?
> 
> The class passed to both ->dump and ->dump_stats is not a classid but
> a qdisc-internal identifier (pointer, integer, whatever) which comes
> from either ->get or ->walk, and thus is valid unless these functions
> have bugs. Your check would cover the bug up and has no other purpose.

Maybe I miss something, but it's not "my check". I tried
only to "stay in line with the remaining file"...

Jarek P.
