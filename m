From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] drivers:net: dma_alloc_coherent: use
 __GFP_ZERO instead of memset(, 0)
Date: Fri, 15 Mar 2013 21:18:21 -0700
Message-ID: <1363407501.2030.1.camel@joe-AO722>
References: <dbbfc5e66dba7d2b63549d218407fb0c4031f2ed.1363367992.git.joe@perches.com>
	 <CFEEE81102D91947B9CC368106979EBA3CF55939@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"b43-dev@lists.infradead.org" <b43-dev@lists.infradead.org>,
	"users@rt2x00.serialmonkey.com" <users@rt2x00.serialmonkey.com>
To: "Abodunrin, Akeem G" <akeem.g.abodunrin@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CFEEE81102D91947B9CC368106979EBA3CF55939@ORSMSX102.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-03-15 at 22:51 +0000, Abodunrin, Akeem G wrote:
> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Joe Perches
[]
> Reduce the number of calls required to alloc a zeroed block of memory.
[]
> diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
[]
> @@ -488,7 +487,6 @@ int igbvf_setup_rx_resources(struct igbvf_adapter *adapter,
>  
>  	rx_ring->desc = dma_alloc_coherent(&pdev->dev, rx_ring->size,
>  					   &rx_ring->dma, GFP_KERNEL);
> -
>  	if (!rx_ring->desc)
>  		goto err;
> 
> Hi Joe,

Hello Akeem.

> Your changes did not seem to make it to igbvf/netdev.c - I think
> instead of removing an extra line added for code clarity, you
> want to add:
> "tx_ring->desc = dma_alloc_coherent(&pdev->dev, tx_ring->size,
>  					   &tx_ring->dma, GFP_KERNEL| __GFP_ZERO);"

Not really, there's no memset here so this
bit is just a whitespace neatening.
