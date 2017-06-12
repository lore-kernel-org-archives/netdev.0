From: David Miller <davem@davemloft.net>
Subject: Re: [net] i40e: fix handling of HW ATR eviction
Date: Mon, 12 Jun 2017 18:53:19 -0400 (EDT)
Message-ID: <20170612.185319.1991996625537854242.davem@davemloft.net>
References: <20170612223837.38940-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacob.e.keller@intel.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45728 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753136AbdFLWxV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 18:53:21 -0400
In-Reply-To: <20170612223837.38940-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 12 Jun 2017 15:38:36 -0700

> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> A recent commit to refactor the driver and remove the hw_disabled_flags
> field accidentally introduced two regressions. First, we overwrote
> pf->flags which removed various key flags including the MSI-X settings.
> 
> Additionally, it was intended that we have now two flags,
> HW_ATR_EVICT_CAPABLe and HW_ATR_EVICT_ENABLED, but this was not done,
> and we accidentally were mis-using HW_ATR_EVICT_CAPABLE everywhere.
> 
> This patch adds the missing piece, HW_ATR_EVICT_ENABLED, and safely
> updates pf->flags instead of overwriting it.
> 
> Without this patch we will have many problems including disabling MSI-X
> support, and we'll attempt to use HW ATR eviction on devices which do
> not support it.
> 
> Fixes: 47994c119a36 ("i40e: remove hw_disabled_flags in favor of using separate flag bits", 2017-04-19)
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.
