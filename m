From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET_SCHED] sch_htb: turn intermediate classes into
 leaves
Date: Fri, 08 Dec 2006 00:27:23 -0800 (PST)
Message-ID: <20061208.002723.118951657.davem@davemloft.net>
References: <456ECDFA.9080207@trash.net>
	<20061130125040.GB2081@ff.dom.local>
	<456ED8C0.4020608@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@o2.pl, netdev@vger.kernel.org, devik@cdi.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50382
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1425163AbWLHI1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 03:27:09 -0500
To: kaber@trash.net
In-Reply-To: <456ED8C0.4020608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 30 Nov 2006 14:12:32 +0100

> Jarek Poplawski wrote:
> > On Thu, Nov 30, 2006 at 01:26:34PM +0100, Patrick McHardy wrote:
> > 
> >>Jarek Poplawski wrote:
> >>
> >>>[NET_SCHED] sch_htb:
> >>>
> >>>[PATCH 2.6.19-rc6 with "Fix endless loops" set of patches]
> >>>
> >>>- turn intermediate classes into leaves again when their
> >>>  last child is deleted (struct htb_class changed)
> >>
> >>Looks good to me too, but it still seems to be missing
> >>class level adjustment after deletion. The classification
> >>function refuses to queue packets to classes with level > 0.
> > 
> > 
> > +static void htb_parent_to_leaf(struct htb_class *cl, struct Qdisc *new_q)
> > +{
> > +	struct htb_class *parent = cl->parent;
> > +
> > +	BUG_TRAP(!cl->level && cl->un.leaf.q && !cl->prio_activity);
> > +
> > +	parent->level = 0;
> > 
> > I've thought this is enough, but probably you mean something
> > else? 
> 
> I missed that, thanks.

Patch applied, thanks again.
