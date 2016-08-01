From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] net/mlx5_core/pagealloc: Remove deprecated
 create_singlethread_workqueue
Date: Mon, 1 Aug 2016 11:11:19 -0400
Message-ID: <20160801151119.GE2542@mtj.duckdns.org>
References: <20160728081949.GA5561@Karyakshetra>
 <20160728093735.GO4628@leon.nu>
 <20160729122237.GG2542@mtj.duckdns.org>
 <20160731063513.GW4628@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
	Matan Barak <matanb@mellanox.com>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	Saeed Mahameed <saeedm@mellanox.com>
To: Leon Romanovsky <leonro@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160731063513.GW4628@leon.nu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Leon.

On Sun, Jul 31, 2016 at 09:35:13AM +0300, Leon Romanovsky wrote:
> > The conversion uses WQ_MEM_RECLAIM, which is standard for all
> > workqueues which can stall packet processing if stalled.  The
> > requirement comes from nfs or block devices over network.
> 
> The title stays "remove deprecated create_singlethread_workqueue" and if
> we put aside the word "deprecated", the code moves from ordered
> workqueue to unordered workqueue and changes max_active count which
> isn't expressed in commit message.

Maybe it was too compressed but the description says

"The workqueue has a single work item. Hence, alloc_workqueue() is
 used instead of alloc_ordered_workqueue() since ordering is
 unnecessary when there's only one work item."

There's only one work item so whether the workqueue is ordered and its
concurrency level don't make any difference.  The reason why people
used to use create_singlethread_workqueue() in these situations was
because per-cpu workqueues used to be very expensive which isn't true
anymore.

> For reclaim paths, I want to be extra caution and want to see
> justification for doing that along with understanding if it is tested or
> not.

WQ_MEM_RECLAIM maintains the behavior of the existing code and the
requirement comes from network interfaces being used for nfs and
transport for block devices and is universial to everything in network
layer.  The only test we can do here is removing it and pushing it
really hard and see whether we can actually trigger deadlock, which it
will under the right circumstances which may or may not be easy to
replicate in test environments.  I don't see many merits in doing this
especially when the behavior doesn't change from the existing code.

> Right now, I'm feeling that I'm participating in soapie where one sends
> patch for every line, waits and sends the same patch for another file.
> It is worth to send one patch set and let us to test it all in once.

Yeah, I guess it can be a bit annoying.  Bhaktipriya, can you please
group patches for meallnox?

Thanks.

-- 
tejun
