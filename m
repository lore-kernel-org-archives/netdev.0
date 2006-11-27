From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_cbq: deactivating when grafting, purging
 etc.
Date: Mon, 27 Nov 2006 10:55:39 +0100
Message-ID: <456AB61B.3040205@trash.net>
References: <20061127065614.GB1625@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:30081 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1757688AbWK0Jzn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 04:55:43 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061127065614.GB1625@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> Here are some fixes proposals suggested by Patrick McHardy.
> 
> [NET_SCHED] sch_cbq:
> 
> - deactivating of active classes when grafting
> 
> - purging of queue/q.qlen adjustment when deleting an active class
> 
> - deactivating of active classes when q.qlen drops to zero in ->drop()
> 
> - a redundant instruction removed from cbq_deactivate_class (my own
>   suggestion)
> 
> PS: - purging of queue and deactivating of active classes
> when attaching a new child - not done (according to man, CBQ can carry
> packets in any type of nodes).


Your patch looks good, but it conflicts with my patches.

One thing I forgot to mention is that it should also have
a callback for deactivating classes when their childs
become empty. If you do that you can just call
disc_tree_decrement_qlen in graft/delete, which will take
care of the qlen decrement and class deactivation.
