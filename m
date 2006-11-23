From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET_SCHED 06/06]: Fix endless loops (part 4): HTB
Date: Thu, 23 Nov 2006 11:59:52 +0100
Message-ID: <20061123105952.GC1586@ff.dom.local>
References: <20061123083909.GA1586@ff.dom.local> <45655F54.2020501@trash.net> <20061123090113.GB1586@ff.dom.local> <456564D4.9010302@trash.net> <45656AAB.3080903@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:58088 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S933579AbWKWKx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 05:53:29 -0500
To: Martin Devera <devik@cdi.cz>
Content-Disposition: inline
In-Reply-To: <45656AAB.3080903@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 23, 2006 at 10:32:27AM +0100, Martin Devera wrote:
> >>>>>+{
> >>>>>+	struct htb_class *cl = (struct htb_class *)arg;
> >>>>>+
> >>>>>+	if (cl->un.leaf.q->q.qlen == 0)
> >>>>
> >>>>Probably "if (cl->prio_activity)" is needed here.
> >>>
> >>>No, the function is only called for active leaf classes, which
> >>>always have prio_activity != 0.
> >>
> >>So this was unnecessary in htb_graft? You should know better...
> >
> >In htb_graft it was necessary because the class could be
> >either active (qlen > 0) or inactive (qlen == 0). But since
> >qdisc_tree_decrease_qlen does nothing in case of a decrease
> >of zero the callback is only called for active classes and
> >the check becomes unnecessary.
> >
> 
> Patrick is right here. prio_activity for leaf is set in htb's enqueue
> routines. The qlen callback is called when len changed and because
> that zero test in htb's callback it is sure the subclass was nonempty
> before.
> The only problem might be if some subqdisc "creates" new packets,
> then htb might deactivate non-active class (leading to BUG()).
> IIRC no qdisc does it...
> devik

I'm learning htb yet and was not sure whether leaf class
with non-zero qlen qdisc couldn't be deactivated for some
other reason. In such case the patch would change
"functionality", so my doubts.

Thanks very much for explanations to both authors of great
schedulers.

I'm very honored,

Jarek P. 

