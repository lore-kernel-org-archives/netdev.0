From: David Rientjes <rientjes@google.com>
Subject: Re: [Patch V3 5/9] i40e: Use numa_mem_id() to better support memoryless
 node
Date: Mon, 17 Aug 2015 17:35:41 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1508171734560.5527@chino.kir.corp.google.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com> <1439781546-7217-6-git-send-email-jiang.liu@linux.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>,
    Mike Galbraith <umgwanakikbuti@gmail.com>,
    Peter Zijlstra <peterz@infradead.org>,
    "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
    Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>,
    Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
    Jesse Brandeburg <jesse.brandeburg@intel.com>,
    Shannon Nelson <shannon.nelson@intel.com>,
    Carolyn Wyborny <carolyn.wyborny@intel.com>,
    Don Skidmore <donald.c.skidmore@intel.com>,
    Matthew Vick <matthew.vick@intel.com>,
    John Ronciak <john.ronciak@intel.com>,
    Mitch Williams <mitch.a.williams@intel.com>,
    Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org,
    linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org,
    x86@kernel.org, intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jiang Liu <jiang.liu@linux.intel.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1439781546-7217-6-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Aug 2015, Jiang Liu wrote:

> Function i40e_clean_rx_irq() tries to reuse memory pages allocated

s/i40e_clean_rx_irq/i40e_clean_rx_irq_ps/

> from the nearest node. To better support memoryless node, use
> numa_mem_id() instead of numa_node_id() to get the nearest node with
> memory.
> 

Out of curiosity, what prevents the cpu to be preempted and current_node 
to no longer match numa_mem_id()?

> This change should only affect performance.
> 
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> index 9a4f2bc70cd2..a8f618cb8eb0 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> @@ -1516,7 +1516,7 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
>  	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
>  	u16 rx_packet_len, rx_header_len, rx_sph, rx_hbo;
>  	u16 cleaned_count = I40E_DESC_UNUSED(rx_ring);
> -	const int current_node = numa_node_id();
> +	const int current_node = numa_mem_id();
>  	struct i40e_vsi *vsi = rx_ring->vsi;
>  	u16 i = rx_ring->next_to_clean;
>  	union i40e_rx_desc *rx_desc;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
