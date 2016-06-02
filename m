From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] net: fjes: fjes_main: Remove create_workqueue
Date: Thu, 2 Jun 2016 10:57:29 -0400
Message-ID: <20160602145729.GO14868@mtj.duckdns.org>
References: <20160602093057.GA15351@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Taku Izumi <izumi.taku@jp.fujitsu.com>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160602093057.GA15351@Karyakshetra>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 02, 2016 at 03:00:57PM +0530, Bhaktipriya Shridhar wrote:
> alloc_workqueue replaces deprecated create_workqueue().
> 
> The workqueue adapter->txrx_wq has workitem
> &adapter->raise_intr_rxdata_task per adapter. Extended Socket Network
> Device is shared memory based, so someone's transmission denotes other's
> reception.  raise_intr_rxdata_task raises interruption of receivers from
> the sender in order to notify receivers.
> 
> The workqueue adapter->control_wq has workitem
> &adapter->interrupt_watch_task per adapter. interrupt_watch_task is used
> to prevent delay of interrupts.
> 
> Dedicated workqueues have been used in both cases since the workitems
> on the workqueues are involved in normal device operation and require
> forward progress under memory pressure.
> 
> max_active has been set to 0 since there is no need for throttling
> the number of active work items.
> 
> Since network devices  may be used for memory reclaim,
> WQ_MEM_RECLAIM has been set to guarantee forward progress.

Patch looks good but ditto with the description.  I wish it were
clearer.

Thanks.

-- 
tejun
