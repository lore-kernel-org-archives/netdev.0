From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 06/12] ixgbe: Add SR-IOV specific modules to driver
 Makefile
Date: Thu, 10 Dec 2009 11:17:39 +1100
Message-ID: <20091210001739.GF4163@verge.net.au>
References: <20091208221258.28373.16663.stgit@localhost.localdomain>
 <20091208221454.28373.78622.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:58017 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758909AbZLJARd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 19:17:33 -0500
Content-Disposition: inline
In-Reply-To: <20091208221454.28373.78622.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2009 at 02:14:55PM -0800, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
> 
> Add the mailbox and SR-IOV feature modules to the ixgbe driver Makefile.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgbe/Makefile |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ixgbe/Makefile b/drivers/net/ixgbe/Makefile
> index 21b41f4..1dd867d 100644
> --- a/drivers/net/ixgbe/Makefile
> +++ b/drivers/net/ixgbe/Makefile
> @@ -33,7 +33,8 @@
>  obj-$(CONFIG_IXGBE) += ixgbe.o
>  
>  ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o \
> -              ixgbe_82599.o ixgbe_82598.o ixgbe_phy.o
> +              ixgbe_82599.o ixgbe_82598.o ixgbe_phy.o ixgbe_sriov.o \
> +              ixgbe_mbx.o
>  
>  ixgbe-$(CONFIG_IXGBE_DCB) +=  ixgbe_dcb.o ixgbe_dcb_82598.o \
>                                ixgbe_dcb_82599.o ixgbe_dcb_nl.o

This change needs to be moved to before
"[RFC PATCH 04/12] ixgbe: Add SR-IOV feature enablement code"
to avoid missing symbols in the driver. But perhaps it would be easier to
just incorporate it into the patch that introduces the new
source files?

$ make
...
WARNING: "mbx_ops_82599" [drivers/net/ixgbe/ixgbe.ko] undefined!

There are more warnings after applying
"[RFC PATCH 05/12] ixgbe: Add SR-IOV features to main module"

$ make
...
WARNING: "mbx_ops_82599" [drivers/net/ixgbe/ixgbe.ko] undefined!
WARNING: "ixgbe_init_mbx_params_pf" [drivers/net/ixgbe/ixgbe.ko] undefined!
WARNING: "ixgbe_vf_configuration" [drivers/net/ixgbe/ixgbe.ko] undefined!
WARNING: "ixgbe_restore_vf_multicasts" [drivers/net/ixgbe/ixgbe.ko] undefined!
WARNING: "ixgbe_msg_task" [drivers/net/ixgbe/ixgbe.ko] undefined!
WARNING: "ixgbe_set_vmolr" [drivers/net/ixgbe/ixgbe.ko] undefined!

