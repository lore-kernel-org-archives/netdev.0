From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] net: ethernet: wiznet: Remove create_workqueue
Date: Wed, 1 Jun 2016 14:46:54 -0400
Message-ID: <20160601184654.GF14868@mtj.duckdns.org>
References: <20160601175914.GA5169@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Antonio Quartulli <a@unstable.cc>,
	Felipe Balbi <felipe.balbi@linux.intel.com>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160601175914.GA5169@Karyakshetra>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 01, 2016 at 11:29:15PM +0530, Bhaktipriya Shridhar wrote:
> alloc_workqueue replaces deprecated create_workqueue().
> 
> A dedicated workqueue has been used since the workitems are involved
> in normal device operation. Workitems &priv->rx_work and &priv->tx_work,
> map to w5100_rx_work and w5100_tx_work respectively and are involved in
> receiving and transmitting packets. Forward progress under
> memory pressure is a requirement here.
> 
> create_workqueue has been replaced with alloc_workqueue with max_active
> as 0 since there is no need for throttling the number of active work
> items.
> 
> Since the driver may be used in memory reclaim path,
> WQ_MEM_RECLAIM has been set to guarantee forward progress.
> 
> flush_workqueue is unnecessary since destroy_workqueue() itself calls
> drain_workqueue() which flushes repeatedly till the workqueue
> becomes empty. Hence the call to flush_workqueue() has been dropped.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
