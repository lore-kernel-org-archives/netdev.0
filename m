From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH 2/4 v2 net-next] net: stmmac: adding multiple buffers for
 RX (fwd)
Date: Thu, 6 Apr 2017 09:23:48 +0100
Message-ID: <6548d134-6a28-7d47-8cf9-8a1742df8f2b@synopsys.com>
References: <alpine.DEB.2.20.1704060728040.2052@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>, <clabbe.montjoie@gmail.com>,
        <treding@nvidia.com>, <niklas.cassel@axis.com>,
        <netdev@vger.kernel.org>, <kbuild-all@01.org>
To: Julia Lawall <julia.lawall@lip6.fr>,
        Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:57226 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751475AbdDFIXy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 04:23:54 -0400
In-Reply-To: <alpine.DEB.2.20.1704060728040.2052@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 6:29 AM de 4/6/2017, Julia Lawall escreveu:
> It looks like an infinite loop, if queue is unsigned.
> 
> julia
> 

Yes you are right, I will fix it, thanks.

Joao

> ---------- Forwarded message ----------
> Date: Thu, 6 Apr 2017 11:49:01 +0800
> From: kbuild test robot <fengguang.wu@intel.com>
> To: kbuild@01.org
> Cc: Julia Lawall <julia.lawall@lip6.fr>
> Subject: Re: [PATCH 2/4 v2 net-next] net: stmmac: adding multiple buffers for RX
> 
> [auto build test WARNING on net-next/master]
> 
> url:    https://urldefense.proofpoint.com/v2/url?u=https-3A__github.com_0day-2Dci_linux_commits_Joao-2DPinto_net-2Dstmmac-2Dbreak-2Dsome-2Dfunctions-2Dinto-2DRX-2Dand-2DTX-2Dscopes_20170406-2D081523&d=DwIBAg&c=DPL6_X_6JkXFx7AXWqB0tg&r=s2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=SF-IM8g8b7VBN_AjT6JxdRBYkTu-2huMLcFlVh_4YKw&s=h9uKHPp4P6ZsYsIGUk0YBvl3ToWDvBWaDUPv5JaNfF4&e= 
> :::::: branch date: 4 hours ago
> :::::: commit date: 4 hours ago
> 
>    drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:2852:15-20: WARNING: Unsigned expression compared with zero: entry < 0
>>> drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1190:8-13: WARNING: Unsigned expression compared with zero: queue >= 0
> 
> git remote add linux-review https://urldefense.proofpoint.com/v2/url?u=https-3A__github.com_0day-2Dci_linux&d=DwIBAg&c=DPL6_X_6JkXFx7AXWqB0tg&r=s2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=SF-IM8g8b7VBN_AjT6JxdRBYkTu-2huMLcFlVh_4YKw&s=q4A5_6A5zp5DRgmx5IJbDiIpc2W3GK3tSNhqpyIaHX8&e= 
> git remote update linux-review
> git checkout b403b5806dca0f85904ddc6cf2241286da86ed9b
> vim +1190 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> 
> b6ad2502 Joao Pinto         2017-04-05  1174  			if (priv->extend_desc)
> b403b580 Joao Pinto         2017-04-05  1175  				priv->hw->mode->init(rx_q->dma_erx,
> b403b580 Joao Pinto         2017-04-05  1176  						     rx_q->dma_rx_phy,
> e3ad57c9 Giuseppe Cavallaro 2016-02-29  1177  						     DMA_RX_SIZE, 1);
> b6ad2502 Joao Pinto         2017-04-05  1178  			else
> b403b580 Joao Pinto         2017-04-05  1179  				priv->hw->mode->init(rx_q->dma_rx,
> b403b580 Joao Pinto         2017-04-05  1180  						     rx_q->dma_rx_phy,
> e3ad57c9 Giuseppe Cavallaro 2016-02-29  1181  						     DMA_RX_SIZE, 0);
> b6ad2502 Joao Pinto         2017-04-05  1182  		}
> b403b580 Joao Pinto         2017-04-05  1183  	}
> b403b580 Joao Pinto         2017-04-05  1184
> b403b580 Joao Pinto         2017-04-05  1185  	buf_sz = bfsize;
> b6ad2502 Joao Pinto         2017-04-05  1186
> b6ad2502 Joao Pinto         2017-04-05  1187  	return 0;
> b403b580 Joao Pinto         2017-04-05  1188
> b6ad2502 Joao Pinto         2017-04-05  1189  err_init_rx_buffers:
> b403b580 Joao Pinto         2017-04-05 @1190  	while (queue >= 0) {
> b6ad2502 Joao Pinto         2017-04-05  1191  		while (--i >= 0)
> b403b580 Joao Pinto         2017-04-05  1192  			stmmac_free_rx_buffer(priv, queue, i);
> b403b580 Joao Pinto         2017-04-05  1193
> b403b580 Joao Pinto         2017-04-05  1194  		i = DMA_RX_SIZE;
> b403b580 Joao Pinto         2017-04-05  1195  		queue--;
> b403b580 Joao Pinto         2017-04-05  1196  	}
> b403b580 Joao Pinto         2017-04-05  1197
> b6ad2502 Joao Pinto         2017-04-05  1198  	return ret;
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://urldefense.proofpoint.com/v2/url?u=https-3A__lists.01.org_pipermail_kbuild-2Dall&d=DwIBAg&c=DPL6_X_6JkXFx7AXWqB0tg&r=s2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=SF-IM8g8b7VBN_AjT6JxdRBYkTu-2huMLcFlVh_4YKw&s=g4EUS_5pRcIV-m5yRBYE0N_JUxlnC68-_z4v2N9zdaU&e=                    Intel Corporation
> 
