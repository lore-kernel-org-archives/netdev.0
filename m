From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH][NET_SCHED] sch_htb: turn intermediate classes into leaves
Date: Thu, 30 Nov 2006 13:50:40 +0100
Message-ID: <20061130125040.GB2081@ff.dom.local>
References: <20061127070401.GA1886@ff.dom.local> <456ABA07.1010508@trash.net> <20061128063948.GA1818@ff.dom.local> <456ECDFA.9080207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:14261 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S936304AbWK3MoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 07:44:01 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <456ECDFA.9080207@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 30, 2006 at 01:26:34PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> > [NET_SCHED] sch_htb:
> > 
> > [PATCH 2.6.19-rc6 with "Fix endless loops" set of patches]
> > 
> > - turn intermediate classes into leaves again when their
> >   last child is deleted (struct htb_class changed)
> 
> Looks good to me too, but it still seems to be missing
> class level adjustment after deletion. The classification
> function refuses to queue packets to classes with level > 0.

+static void htb_parent_to_leaf(struct htb_class *cl, struct Qdisc *new_q)
+{
+	struct htb_class *parent = cl->parent;
+
+	BUG_TRAP(!cl->level && cl->un.leaf.q && !cl->prio_activity);
+
+	parent->level = 0;

I've thought this is enough, but probably you mean something
else? 

Jarek P.
