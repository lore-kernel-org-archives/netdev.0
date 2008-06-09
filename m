From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] ixgbe: add LRO support
Date: Tue, 10 Jun 2008 00:26:29 +0100
Message-ID: <20080609232627.GM11300@solarflare.com>
References: <20080609225658.1219.89600.stgit@localhost.localdomain>
	<20080609225722.1219.51519.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jeff@garzik.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080609225722.1219.51519.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Jeff Kirsher wrote:
> Support for in-kernel LRO
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe.h         |    9 +++
>  drivers/net/ixgbe/ixgbe_ethtool.c |    9 +++
>  drivers/net/ixgbe/ixgbe_main.c    |  111 ++++++++++++++++++++++++++++++-------
>  3 files changed, 108 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
> index d981134..956914a 100644
> --- a/drivers/net/ixgbe/ixgbe.h
> +++ b/drivers/net/ixgbe/ixgbe.h
> @@ -32,6 +32,7 @@
>  #include <linux/types.h>
>  #include <linux/pci.h>
>  #include <linux/netdevice.h>
> +#include <linux/inet_lro.h>
>  
>  #include "ixgbe_type.h"
>  #include "ixgbe_common.h"
> @@ -100,6 +101,9 @@
>  #define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
>  #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
>  
> +#define IXGBE_MAX_LRO_DESCRIPTORS       8
> +#define IXGBE_MAX_LRO_AGGREGATE         32

I think this is supposed to be <= MAX_SKB_FRAGS, though that's only
critical if you aggregating pages.

[...]
> @@ -3517,6 +3585,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
>  			   NETIF_F_HW_VLAN_RX |
>  			   NETIF_F_HW_VLAN_FILTER;
>  
> +	netdev->features |= NETIF_F_LRO;

There needs to be a way of turning LRO off.  It should be sufficient
to add:

	.get_flags =	ethtool_op_get_flags,
	.set_flags =	ethtool_op_set_flags,

to your ethtool_ops.  A module parameter to set the default might be
worthwhile too.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
