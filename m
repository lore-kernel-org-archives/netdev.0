From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH][NET_SCHED] sch_cbq: deactivating when grafting, purging etc.
Date: Mon, 27 Nov 2006 11:41:40 +0100
Message-ID: <20061127104140.GA2866@ff.dom.local>
References: <20061127065614.GB1625@ff.dom.local> <456AB61B.3040205@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:3471 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1758002AbWK0KfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 05:35:06 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <456AB61B.3040205@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 27, 2006 at 10:55:39AM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> > Here are some fixes proposals suggested by Patrick McHardy.
> > 
> > [NET_SCHED] sch_cbq:
> > 
> > - deactivating of active classes when grafting
> > 
> > - purging of queue/q.qlen adjustment when deleting an active class
> > 
> > - deactivating of active classes when q.qlen drops to zero in ->drop()
> > 
> > - a redundant instruction removed from cbq_deactivate_class (my own
> >   suggestion)
> > 
> > PS: - purging of queue and deactivating of active classes
> > when attaching a new child - not done (according to man, CBQ can carry
> > packets in any type of nodes).
> 
> 
> Your patch looks good, but it conflicts with my patches.

I know, but I wasn't sure which version this changes
are needed for. If there will be something more to do,
name the version, please. 
 
> One thing I forgot to mention is that it should also have
> a callback for deactivating classes when their childs
> become empty. If you do that you can just call
> disc_tree_decrement_qlen in graft/delete, which will take
> care of the qlen decrement and class deactivation.
 
If I understand correctly I should apply this to 
the version after your patch (plus the missing cbq part
of "endless loops"). I'll try.

