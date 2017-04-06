From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 2/4 v2 net-next] net: stmmac: adding multiple buffers
 for RX (fwd)
Date: Thu, 6 Apr 2017 07:29:13 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1704060728040.2052@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, clabbe.montjoie@gmail.com, treding@nvidia.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>, kbuild-all@01.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:3725 "EHLO
        mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751824AbdDFF3R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 01:29:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like an infinite loop, if queue is unsigned.

julia

---------- Forwarded message ----------
Date: Thu, 6 Apr 2017 11:49:01 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 2/4 v2 net-next] net: stmmac: adding multiple buffers for RX

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Joao-Pinto/net-stmmac-break-some-functions-into-RX-and-TX-scopes/20170406-081523
:::::: branch date: 4 hours ago
:::::: commit date: 4 hours ago

   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:2852:15-20: WARNING: Unsigned expression compared with zero: entry < 0
>> drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1190:8-13: WARNING: Unsigned expression compared with zero: queue >= 0

git remote add linux-review https://github.com/0day-ci/linux
git remote update linux-review
git checkout b403b5806dca0f85904ddc6cf2241286da86ed9b
vim +1190 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c

b6ad2502 Joao Pinto         2017-04-05  1174  			if (priv->extend_desc)
b403b580 Joao Pinto         2017-04-05  1175  				priv->hw->mode->init(rx_q->dma_erx,
b403b580 Joao Pinto         2017-04-05  1176  						     rx_q->dma_rx_phy,
e3ad57c9 Giuseppe Cavallaro 2016-02-29  1177  						     DMA_RX_SIZE, 1);
b6ad2502 Joao Pinto         2017-04-05  1178  			else
b403b580 Joao Pinto         2017-04-05  1179  				priv->hw->mode->init(rx_q->dma_rx,
b403b580 Joao Pinto         2017-04-05  1180  						     rx_q->dma_rx_phy,
e3ad57c9 Giuseppe Cavallaro 2016-02-29  1181  						     DMA_RX_SIZE, 0);
b6ad2502 Joao Pinto         2017-04-05  1182  		}
b403b580 Joao Pinto         2017-04-05  1183  	}
b403b580 Joao Pinto         2017-04-05  1184
b403b580 Joao Pinto         2017-04-05  1185  	buf_sz = bfsize;
b6ad2502 Joao Pinto         2017-04-05  1186
b6ad2502 Joao Pinto         2017-04-05  1187  	return 0;
b403b580 Joao Pinto         2017-04-05  1188
b6ad2502 Joao Pinto         2017-04-05  1189  err_init_rx_buffers:
b403b580 Joao Pinto         2017-04-05 @1190  	while (queue >= 0) {
b6ad2502 Joao Pinto         2017-04-05  1191  		while (--i >= 0)
b403b580 Joao Pinto         2017-04-05  1192  			stmmac_free_rx_buffer(priv, queue, i);
b403b580 Joao Pinto         2017-04-05  1193
b403b580 Joao Pinto         2017-04-05  1194  		i = DMA_RX_SIZE;
b403b580 Joao Pinto         2017-04-05  1195  		queue--;
b403b580 Joao Pinto         2017-04-05  1196  	}
b403b580 Joao Pinto         2017-04-05  1197
b6ad2502 Joao Pinto         2017-04-05  1198  	return ret;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
