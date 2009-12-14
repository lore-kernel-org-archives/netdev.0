From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/3] ixgbe: Fix tx_restart_queue/non_eop_desc
 statistics counters
Date: Sun, 13 Dec 2009 19:18:04 -0800 (PST)
Message-ID: <20091213.191804.226782424.davem@davemloft.net>
References: <20091212075120.10952.98484.stgit@localhost.localdomain>
	<20091212075140.10952.86813.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54446
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932143AbZLNDSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 22:18:02 -0500
In-Reply-To: <20091212075140.10952.86813.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 11 Dec 2009 23:51:41 -0800

> @@ -4528,10 +4529,12 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
>  
>  	/* gather some stats to the adapter struct that are per queue */
>  	for (i = 0; i < adapter->num_tx_queues; i++)
> -		adapter->restart_queue += adapter->tx_ring[i].restart_queue;
> +		restart_queue += adapter->tx_ring[i]->restart_queue;
> +	adapter->restart_queue = restart_queue;

I don't see how these two versions of the code can behave
differently unless there is very broken locking on the
adapter->* statistic counters.

I'm not applying this without at least a better commit
log message.
