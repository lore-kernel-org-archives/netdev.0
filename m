From: "Singh, Krishneil K" <krishneil.k.singh@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] net: ethernet: intel: fm10k: Remove
	create_workqueue
Date: Mon, 11 Jul 2016 19:21:25 +0000
Message-ID: <EF50CC0C76A53A44BAD798C58E0A157E273A1832@ORSMSX103.amr.corp.intel.com>
References: <20160601154009.GA31043@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Tejun Heo <tj@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160601154009.GA31043@Karyakshetra>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Bhaktipriya Shridhar
Sent: Wednesday, June 1, 2016 8:40 AM
To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
Cc: Tejun Heo <tj@kernel.org>; netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org; linux-kernel@vger.kernel.org
Subject: [Intel-wired-lan] [PATCH] net: ethernet: intel: fm10k: Remove create_workqueue

alloc_workqueue replaces deprecated create_workqueue().

A dedicated workqueue has been used since the workitem (viz fm10k_service_task, which manages and runs other subtasks) is involved in normal device operation and requires forward progress under memory pressure.

create_workqueue has been replaced with alloc_workqueue with max_active as 0 since there is no need for throttling the number of active work items.

Since network devices may be used in memory reclaim path, WQ_MEM_RECLAIM has been set to guarantee forward progress.

flush_workqueue is unnecessary since destroy_workqueue() itself calls
drain_workqueue() which flushes repeatedly till the workqueue becomes empty. Hence the call to flush_workqueue() has been dropped.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---

Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
