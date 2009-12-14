From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-2.6 PATCH 2/3] ixgbe: Fix tx_restart_queue/non_eop_desc
 statistics counters
Date: Sun, 13 Dec 2009 20:57:05 -0800
Message-ID: <1260766625.20884.2.camel@localhost>
References: <20091212075120.10952.98484.stgit@localhost.localdomain>
	 <20091212075140.10952.86813.stgit@localhost.localdomain>
	 <20091213.191804.226782424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Chilakala, Mallikarjuna" <mallikarjuna.chilakala@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:23394 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756310AbZLNE5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 23:57:06 -0500
In-Reply-To: <20091213.191804.226782424.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-12-13 at 19:18 -0800, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri, 11 Dec 2009 23:51:41 -0800
> 
> > @@ -4528,10 +4529,12 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
> >  
> >  	/* gather some stats to the adapter struct that are per queue */
> >  	for (i = 0; i < adapter->num_tx_queues; i++)
> > -		adapter->restart_queue += adapter->tx_ring[i].restart_queue;
> > +		restart_queue += adapter->tx_ring[i]->restart_queue;
> > +	adapter->restart_queue = restart_queue;
> 
> I don't see how these two versions of the code can behave
> differently unless there is very broken locking on the
> adapter->* statistic counters.

The problem is the adapter->restart_queue is being double-counted.  If
we accumulate from each ring's restart_queue, which are cumulative, then
we don't want to add it to the previous update_stats() values in
adapter->restart_queue.

> I'm not applying this without at least a better commit
> log message.

We can fix the commit log message to better explain what the problem is.

Thanks,
-PJ

