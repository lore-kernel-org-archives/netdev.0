From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlxsw: core: Remove deprecated create_workqueue
Date: Thu, 09 Jun 2016 23:50:05 -0700 (PDT)
Message-ID: <20160609.235005.436161549558871599.davem@davemloft.net>
References: <20160607195946.GA11743@Karyakshetra>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, idosch@mellanox.com, tj@kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhaktipriya96@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160607195946.GA11743@Karyakshetra>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Date: Wed, 8 Jun 2016 01:29:46 +0530

> alloc_workqueue replaces deprecated create_workqueue().
> 
> A dedicated workqueue has been used since the workqueue
> mlxsw_wq is used for FDB notif. processing with workitems that are
> involved in normal device operation && because it's a network device
> which can be depended upon during memory reclaim.
> 
> Workitems &trans->timeout_dw and &mlxsw_sp->fdb_notify.dw,
> map to mlxsw_sp_fdb_notify_work (processes FDB notifications from the
> underlying device and resolves the netdev to which the entry points to
> and notifies the bridge using the switchdev notifier) and
> mlxsw_emad_trans_timeout_work (provides async EMAD register access)
> respectively. They require forward progress under memory pressure and
> hence, WQ_MEM_RECLAIM has been set.
> 
> Since there are only a fixed number of work items, explicit concurrency
> limit is unnecessary here.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

Applied.
