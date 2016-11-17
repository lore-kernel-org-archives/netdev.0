From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v2 3/3] net: marvell: Allow drivers to be built with COMPILE_TEST
Date: Thu, 17 Nov 2016 10:10:04 +0100
Message-ID: <3919859.qNQH5uJBHH@wuerfel>
References: <201611171025.rUxQZT0L%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, kbuild-all@01.org,
        netdev@vger.kernel.org, davem@davemloft.net, mw@semihalf.com,
        gregory.clement@free-electrons.com, Shaohui.Xie@freescale.com
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:56084 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751518AbcKQJKb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 04:10:31 -0500
In-Reply-To: <201611171025.rUxQZT0L%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, November 17, 2016 10:30:10 AM CET kbuild test robot wrote:
> 
> url:    https://github.com/0day-ci/linux/commits/Florian-Fainelli/net-fsl-Allow-most-drivers-to-be-built-with-COMPILE_TEST/20161116-094841
> config: m32r-allmodconfig (attached as .config)
> compiler: m32r-linux-gcc (GCC) 6.2.0
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=m32r 
> 
> All errors (new ones prefixed by >>):
> 
>    ERROR: "bad_dma_ops" [sound/core/snd-pcm.ko] undefined!
>    ERROR: "dma_common_mmap" [sound/core/snd-pcm.ko] undefined!
> >> ERROR: "bad_dma_ops" [drivers/net/ethernet/marvell/mvpp2.ko] undefined!
>    ERROR: "mvebu_mbus_get_dram_win_info" [drivers/net/ethernet/marvell/mvneta_bm.ko] undefined!
> >> ERROR: "bad_dma_ops" [drivers/net/ethernet/marvell/mvneta_bm.ko] undefined!
> >> ERROR: "bad_dma_ops" [drivers/net/ethernet/marvell/mvneta.ko] undefined!
> >> ERROR: "bad_dma_ops" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
>    ERROR: "bad_dma_ops" [drivers/net/ethernet/freescale/gianfar_driver.ko] undefined!
> 
> 

This can be avoided by adding 'depends on HAS_DMA'. We should probably just
fix m32r instead to not require that and allow building all drivers even when
they can't work in the end.

	Arnd
