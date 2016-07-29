From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] net/mlx5_core/en_main: Remove deprecated create_workqueue
Date: Fri, 29 Jul 2016 08:25:16 -0400
Message-ID: <20160729122516.GH2542@mtj.duckdns.org>
References: <20160727061229.GA16943@Karyakshetra>
 <CALzJLG_B4q2TeAy9U+8nZisYtw8+MfwT8or81mBsPJ=VFLxBqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALzJLG_B4q2TeAy9U+8nZisYtw8+MfwT8or81mBsPJ=VFLxBqw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Fri, Jul 29, 2016 at 01:30:05AM +0300, Saeed Mahameed wrote:
> > Are the workitems being used on a memory reclaim path?
> 
> do you mean they need to allocate memory ?

It's a bit convoluted.  A workqueue needs WQ_MEM_RECLAIM flag to be
guaranteed forward progress under memory pressure, so any workqueue
which may be depended upon during memory reclaim should have the flag
set; otherwise, the system can deadlock (try to reclaim memory, hits
the wq which can't make forward progress due to lack of memory).  For
network devices, the requirement comes from block-over-network or nfs
which can be involved in memory reclaim.

Thanks.

-- 
tejun
