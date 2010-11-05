From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: Re: [PATCH 26/49] drivers/net/ixgbevf: Use vzalloc
Date: Fri, 5 Nov 2010 04:59:22 -0700
Message-ID: <43F901BD926A4E43B106BF17856F07550124A9DFFF@orsmsx508.amr.corp.intel.com>
References: <cover.1288925424.git.joe@perches.com>
	<79b773f5012cba15686c4048d48cbbef6a13b049.1288925425.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ronciak, John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>, Jiri Kosina <trivial@kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <79b773f5012cba15686c4048d48cbbef6a13b049.1288925425.git.joe@perches.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Thursday, November 04, 2010 8:08 PM
> To: Jiri Kosina
> Cc: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Wyborny,
> Carolyn; Skidmore, Donald C; Rose, Gregory V; Waskiewicz Jr, Peter P;
> Duyck, Alexander H; Ronciak, John; e1000-devel@lists.sourceforge.net;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [PATCH 26/49] drivers/net/ixgbevf: Use vzalloc
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ixgbevf/ixgbevf_main.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ixgbevf/ixgbevf_main.c
> b/drivers/net/ixgbevf/ixgbevf_main.c
> index dc03c96..6aeaf54 100644
> --- a/drivers/net/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ixgbevf/ixgbevf_main.c
> @@ -2488,10 +2488,9 @@ int ixgbevf_setup_tx_resources(struct
> ixgbevf_adapter *adapter,
>  	int size;
> 
>  	size = sizeof(struct ixgbevf_tx_buffer) * tx_ring->count;
> -	tx_ring->tx_buffer_info = vmalloc(size);
> +	tx_ring->tx_buffer_info = vzalloc(size);
>  	if (!tx_ring->tx_buffer_info)
>  		goto err;
> -	memset(tx_ring->tx_buffer_info, 0, size);
> 
>  	/* round up to nearest 4K */
>  	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc);
> @@ -2555,14 +2554,13 @@ int ixgbevf_setup_rx_resources(struct
> ixgbevf_adapter *adapter,
>  	int size;
> 
>  	size = sizeof(struct ixgbevf_rx_buffer) * rx_ring->count;
> -	rx_ring->rx_buffer_info = vmalloc(size);
> +	rx_ring->rx_buffer_info = vzalloc(size);
>  	if (!rx_ring->rx_buffer_info) {
>  		hw_dbg(&adapter->hw,
>  		       "Unable to vmalloc buffer memory for "
>  		       "the receive descriptor ring\n");
>  		goto alloc_failed;
>  	}
> -	memset(rx_ring->rx_buffer_info, 0, size);
> 
>  	/* Round up to nearest 4K */
>  	rx_ring->size = rx_ring->count * sizeof(union ixgbe_adv_rx_desc);
> --
> 1.7.3.1.g432b3.dirty

Acked By: Greg Rose <Gregory.v.rose@intel.com>


------------------------------------------------------------------------------
The Next 800 Companies to Lead America's Growth: New Video Whitepaper
David G. Thomson, author of the best-selling book "Blueprint to a 
Billion" shares his insights and actions to help propel your 
business during the next growth cycle. Listen Now!
http://p.sf.net/sfu/SAP-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
