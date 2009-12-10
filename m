From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 03/12] ixgbe: Add SR-IOV register, structure and
 bit defines
Date: Thu, 10 Dec 2009 11:06:35 +1100
Message-ID: <20091210000634.GE4163@verge.net.au>
References: <20091208221258.28373.16663.stgit@localhost.localdomain>
 <20091208221350.28373.42808.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:56201 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758700AbZLJAG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 19:06:29 -0500
Content-Disposition: inline
In-Reply-To: <20091208221350.28373.42808.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2009 at 02:13:51PM -0800, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
> 
> This patch adds register definitions, bit definitions and structures used by
> the SW to support SR-IOV features of the 82599 controller.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe.h      |   31 +++++++++++++++++++++++++--
>  drivers/net/ixgbe/ixgbe_type.h |   46 ++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 75 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h

[snip]

> @@ -440,6 +466,7 @@ extern s32 ixgbe_atr_set_flex_byte_82599(struct ixgbe_atr_input *input,
>                                           u16 flex_byte);
>  extern s32 ixgbe_atr_set_l4type_82599(struct ixgbe_atr_input *input,
>                                        u8 l4type);
> +extern void ixgbe_set_rx_mode(struct net_device *netdev);
>  #ifdef IXGBE_FCOE
>  extern void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter);
>  extern int ixgbe_fso(struct ixgbe_adapter *adapter,

Making ixgbe_set_rx_mode() non-static in ixgbe_main.c needs to be moved
forward from patch "[RFC PATCH 05/12] ixgbe: Add SR-IOV features to main
module" into this patch to avoid breaking the build.

$ make
...
  CC [M]  drivers/net/ixgbe/ixgbe_main.o
drivers/net/ixgbe/ixgbe_main.c:2402: error: static declaration of 'ixgbe_set_rx_mode' follows non-static declaration
drivers/net/ixgbe/ixgbe.h:470: error: previous declaration of 'ixgbe_set_rx_mode' was here
make[1]: *** [drivers/net/ixgbe/ixgbe_main.o] Error 1
make: *** [_module_drivers/net/ixgbe] Error 2
