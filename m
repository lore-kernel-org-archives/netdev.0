From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 06/12] nfp: add stats and xmit helpers for
 representors
Date: Tue, 20 Jun 2017 22:48:05 +0200
Message-ID: <20170620204804.GA6157@vergenet.net>
References: <1497937910-32059-7-git-send-email-simon.horman@netronome.com>
 <201706210132.VUFkNyd8%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:33043 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751131AbdFTUsJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 16:48:09 -0400
Received: by mail-wr0-f182.google.com with SMTP id r103so107141657wrb.0
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 13:48:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <201706210132.VUFkNyd8%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 21, 2017 at 01:15:05AM +0800, kbuild test robot wrote:
> Hi Simon,
> 
> [auto build test ERROR on net-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Simon-Horman/nfp-add-flower-app-with-representors/20170620-233831
> config: arm-allmodconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm 

It seems that I forgot to add

#include <linux/io-64-nonatomic-hi-lo.h>

I will do so in v2.

> 
> All errors (new ones prefixed by >>):
> 
>    drivers/net//ethernet/netronome/nfp/nfp_net_repr.c: In function 'nfp_repr_phy_port_get_stats64':
> >> drivers/net//ethernet/netronome/nfp/nfp_net_repr.c:88:22: error: implicit declaration of function 'readq' [-Werror=implicit-function-declaration]
>      stats->tx_packets = readq(mem + NFP_MAC_STATS_RX_FRAMES_RECEIVED_OK);
>                          ^~~~~
>    cc1: some warnings being treated as errors
> 
> vim +/readq +88 drivers/net//ethernet/netronome/nfp/nfp_net_repr.c
> 
>     72		stats->rx_packets++;
>     73		stats->rx_bytes += len;
>     74		u64_stats_update_end(&stats->syncp);
>     75	}
>     76	
>     77	void
>     78	nfp_repr_phy_port_get_stats64(const struct nfp_app *app, u8 phy_port,
>     79				      struct rtnl_link_stats64 *stats)
>     80	{
>     81		u8 __iomem *mem;
>     82	
>     83		mem = app->pf->mac_stats_mem + phy_port * NFP_MAC_STATS_SIZE;
>     84	
>     85		/* TX and RX stats are flipped as we are returning the stats as seen
>     86		 * at the switch port corresponding to the phys port.
>     87		 */
>   > 88		stats->tx_packets = readq(mem + NFP_MAC_STATS_RX_FRAMES_RECEIVED_OK);
>     89		stats->tx_bytes = readq(mem + NFP_MAC_STATS_RX_IN_OCTETS);
>     90		stats->tx_dropped = readq(mem + NFP_MAC_STATS_RX_IN_ERRORS);
>     91	
>     92		stats->rx_packets = readq(mem + NFP_MAC_STATS_TX_FRAMES_TRANSMITTED_OK);
>     93		stats->rx_bytes = readq(mem + NFP_MAC_STATS_TX_OUT_OCTETS);
>     94		stats->rx_dropped = readq(mem + NFP_MAC_STATS_TX_OUT_ERRORS);
>     95	}
>     96	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
