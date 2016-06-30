From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH V2 2/4] net-next: mediatek: don't use intermediate
 variables to store IRQ masks
Date: Thu, 30 Jun 2016 09:33:33 +0200
Message-ID: <3eb8dd5f-7b21-a2f5-dbd5-9016bf328753@phrozen.org>
References: <201606301404.EoyOs9Sz%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Sean Wang <keyhaede@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
	kbuild-all@01.org, "David S. Miller" <davem@davemloft.net>,
	Felix Fietkau <nbd@nbd.name>
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201606301404.EoyOs9Sz%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 30/06/2016 08:03, kbuild test robot wrote:
> Hi,
> 
> [auto build test ERROR on net/master]
> [also build test ERROR on v4.7-rc5 next-20160629]
> [cannot apply to net-next/master]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/John-Crispin/net-next-mediatek-IRQ-cleanups-fixes-and-grouping/20160629-194341
> config: arm-allmodconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 5.3.1-8) 5.3.1 20160205
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm 
> 
> Note: the linux-review/John-Crispin/net-next-mediatek-IRQ-cleanups-fixes-and-grouping/20160629-194341 HEAD e8462c612b33003fba7c1a70328c7fb7872d8507 builds fine.
>       It only hurts bisectibility.
> 
> All errors (new ones prefixed by >>):
> 
>    drivers/net/ethernet/mediatek/mtk_eth_soc.c: In function 'mtk_poll':
>>> drivers/net/ethernet/mediatek/mtk_eth_soc.c:1003:16: error: 'tx_intr' undeclared (first use in this function)
>      if (status & (tx_intr | rx_intr))
>                    ^
>    drivers/net/ethernet/mediatek/mtk_eth_soc.c:1003:16: note: each undeclared identifier is reported only once for each function it appears in
>>> drivers/net/ethernet/mediatek/mtk_eth_soc.c:1003:26: error: 'rx_intr' undeclared (first use in this function)
>      if (status & (tx_intr | rx_intr))
>                              ^
> 
> vim +/tx_intr +1003 drivers/net/ethernet/mediatek/mtk_eth_soc.c
> 
> 656e7052 John Crispin 2016-03-08   997  	}
> 656e7052 John Crispin 2016-03-08   998  
> 656e7052 John Crispin 2016-03-08   999  	if (tx_again || rx_done == budget)
> 656e7052 John Crispin 2016-03-08  1000  		return budget;
> 656e7052 John Crispin 2016-03-08  1001  
> 656e7052 John Crispin 2016-03-08  1002  	status = mtk_r32(eth, MTK_QMTK_INT_STATUS);
> 656e7052 John Crispin 2016-03-08 @1003  	if (status & (tx_intr | rx_intr))
> 656e7052 John Crispin 2016-03-08  1004  		return budget;
> 656e7052 John Crispin 2016-03-08  1005  
> 656e7052 John Crispin 2016-03-08  1006  	napi_complete(napi);
> 
> :::::: The code at line 1003 was first introduced by commit
> :::::: 656e705243fd0c2864b89634ea16ed444ef64dc6 net-next: mediatek: add support for MT7623 ethernet
> 
> :::::: TO: John Crispin <blogic@openwrt.org>
> :::::: CC: David S. Miller <davem@davemloft.net>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

Hi,

This series depends on a previous series currently sitting in net.git
starting with
	commit 562c5a70400c ("net: mediatek: only wake the queue if it is stopped")
up to
	commit 82c6544dddc6 ("net: mediatek: remove superfluous queue wake up
call")

i just double checked and with the series applied this compile error is gone

	John
