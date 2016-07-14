From: Matt Wilson <msw@amzn.com>
Subject: Re: [PATCH net-next V3] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Thu, 14 Jul 2016 08:22:15 -0700
Message-ID: <20160714152215.GA24590@u54ee753d2d1854bda401.ant.amazon.com>
References: <1468478774-19942-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com,
	aliguori@amazon.com, ben@decadent.org.uk, romieu@fr.zoreil.com,
	rami.rosen@intel.com, antoine.tenart@free-electrons.com
To: Netanel Belgazal <netanel@annapurnalabs.com>,
	Benjamin Poirier <benjamin.poirier@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-33001.amazon.com ([207.171.189.228]:45195 "EHLO
	smtp-fw-33001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbcGNPWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 11:22:24 -0400
Content-Disposition: inline
In-Reply-To: <1468478774-19942-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 14, 2016 at 09:46:14AM +0300, Netanel Belgazal wrote:
> This is a driver for the ENA family of networking devices.
> 
> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
> ---
> 
> Notes:
>     Changes in v3:
>     - Fix compilation warning for 32bit systems. [kbuild test rebot]
>     - Replace netdev->num_tx_queues with adapter->num_queues in ethtool. [ben@decadent.org.uk]
>     - Use get_link_ksettings instread of get_settings (deprecated ethtool API). [ben@decadent.org.uk]
>     - Remove rna_nway_reset (ethtool). [ben@decadent.org.uk]
>     - Add missing break in switch condition. [ben@decadent.org.uk]
>     - Increase driver version to 1.0.2
>     
>     Changes in v2:
>     - Increment driver version to 1.0.1
>     - Reorder the initialization of the workqueus and the timer service
>     - Initialize last_keep_alive_jiffies in probe
>     - Remove ena_trc_* functions in favor of pr_* [davem@davemloft.net]
>     - Fix Tx interrupt control register value [romieu@fr.zoreil.com]
>     - Edit ena.txt to focus on technical details [romieu@fr.zoreil.com]
>     - Rename small_copy_len tunable to rx_copybreak [benjamin.poirier@gmail.com]
>     - Change uint32_t to u32 [romieu@fr.zoreil.com]
>     - Return error in ena_com_set_hash_ctrl [rami.rosen@intel.com]
>     - Fix API documentation [rami.rosen@intel.com]
>     - Remove redundant check in ena_com_mem_addr_set [romieu@fr.zoreil.com]
>     - Add local variables for allocation methods to improve readability [romieu@fr.zoreil.com]
>     - Replace dma_alloc_coherent and __GFP_ZERO flag with dma_zalloc_coherent [romieu@fr.zoreil.com]
>     - Fix style when using dma_alloc_coherent [romieu@fr.zoreil.com]
>     - Tx xmit - In case of an error drop the packet and return NETDEV_TX_OK [romieu@fr.zoreil.com]
>     - Reduce the number of parameters in ena_get_dev_stats [romieu@fr.zoreil.com]
>     - Return ret and not 0 in ena_com_set_hash_ctrl [rami.rosen@intel.com]
>     - Do not initialize variables if the function doesn't read them before the second write [romieu@fr.zoreil.com]
>     - Enums - Replace space with tabs to line the assign value [romieu@fr.zoreil.com]
>     - Remove redundant comments [romieu@fr.zoreil.com]
>     
>     TODO:
>     - Add bytes variable to set_coalesce ethtool callback and use this callback
>       instead of dedicated sysfs files.

Dave and Benjamin,

Do you want to see the interrupt moderation extensions to ethtool and
the sysfs nodes removed before this lands in net-next? Or should
Netanel remove the sysfs bits until we can extend the ethtool
interfaces to cover the parameters that ena uses?

--msw
