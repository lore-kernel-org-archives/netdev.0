From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: Re: [patch net v2] net: fec: fix compile with CONFIG_M5272
Date: Mon, 5 Dec 2016 17:03:31 +0300
Message-ID: <113aa199-9b9f-c215-bfcc-251b8c7e85f7@cogentembedded.com>
References: <201612052104.HSl9jlj9%fengguang.wu@intel.com>
 <60acf0f4-2f1f-2b2c-06ed-b1d8cb03525d@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, "David S. Miller" <davem@davemloft.net>,
        Fugang Duan <fugang.duan@nxp.com>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Andrew Lunn <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        netdev@vger.kernel.org, Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        linux-kernel@vger.kernel.org
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <60acf0f4-2f1f-2b2c-06ed-b1d8cb03525d@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff --git a/drivers/net/ethernet/freescale/fec_main.c
b/drivers/net/ethernet/freescale/fec_main.c
index 741cf4a57bfc..12aef1b15356 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3301,7 +3301,7 @@ fec_probe(struct platform_device *pdev)

 	/* Init network device */
 	ndev = alloc_etherdev_mqs(sizeof(struct fec_enet_private) +
-				  FEC_STAT_SIZE, num_tx_qs, num_rx_qs);
+				  FEC_STATS_SIZE, num_tx_qs, num_rx_qs);
 	if (!ndev)
 		return -ENOMEM;


> Aieee   I was typing too fast today, sorry...
> 
> send separate "fix for the fix", or re-send patch without that silly typo?
> 
> Nikita
> 
>> Hi Nikita,
>>
>> [auto build test ERROR on net/master]
>>
>> url:    https://github.com/0day-ci/linux/commits/Nikita-Yushchenko/net-fec-fix-compile-with-CONFIG_M5272/20161205-181735
>> config: arm-multi_v5_defconfig (attached as .config)
>> compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
>> reproduce:
>>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>>         chmod +x ~/bin/make.cross
>>         # save the attached .config to linux build tree
>>         make.cross ARCH=arm 
>>
>> All errors (new ones prefixed by >>):
>>
>>    drivers/net/ethernet/freescale/fec_main.c: In function 'fec_probe':
>>>> drivers/net/ethernet/freescale/fec_main.c:3304:7: error: 'FEC_STAT_SIZE' undeclared (first use in this function)
>>           FEC_STAT_SIZE, num_tx_qs, num_rx_qs);
>>           ^~~~~~~~~~~~~
>>    drivers/net/ethernet/freescale/fec_main.c:3304:7: note: each undeclared identifier is reported only once for each function it appears in
>>
>> vim +/FEC_STAT_SIZE +3304 drivers/net/ethernet/freescale/fec_main.c
>>
>>   3298		int num_rx_qs;
>>   3299	
>>   3300		fec_enet_get_queue_num(pdev, &num_tx_qs, &num_rx_qs);
>>   3301	
>>   3302		/* Init network device */
>>   3303		ndev = alloc_etherdev_mqs(sizeof(struct fec_enet_private) +
>>> 3304					  FEC_STAT_SIZE, num_tx_qs, num_rx_qs);
>>   3305		if (!ndev)
>>   3306			return -ENOMEM;
>>   3307	
>>
>> ---
>> 0-DAY kernel test infrastructure                Open Source Technology Center
>> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>>
