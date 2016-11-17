From: Fengguang Wu <lkp@intel.com>
Subject: Re: [PATCH net-next v3 2/3] net: fsl: Allow most drivers to be built
 with COMPILE_TEST
Date: Thu, 17 Nov 2016 09:38:23 +0800
Message-ID: <20161117013823.ne3f3dpvs64j5gmw@wfg-t540p.sh.intel.com>
References: <201611161135.ksuIHp17%fengguang.wu@intel.com>
 <0216ebc6-1889-6ca7-974c-90524ed61651@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net,
        mw@semihalf.com, arnd@arndb.de, gregory.clement@free-electrons.com,
        Shaohui.Xie@freescale.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2226 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753565AbcKQBi2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 20:38:28 -0500
Content-Disposition: inline
In-Reply-To: <0216ebc6-1889-6ca7-974c-90524ed61651@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2016 at 11:52:45AM -0800, Florian Fainelli wrote:
>On 11/15/2016 07:23 PM, kbuild test robot wrote:
>> Hi Florian,
>>
>> [auto build test WARNING on net-next/master]
>>
>> url:    https://github.com/0day-ci/linux/commits/Florian-Fainelli/net-gianfar_ptp-Rename-FS-bit-to-FIPERST/20161116-095805
>> config: sh-allmodconfig (attached as .config)
>> compiler: sh4-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
>> reproduce:
>>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>>         chmod +x ~/bin/make.cross
>>         # save the attached .config to linux build tree
>>         make.cross ARCH=sh
>>
>> All warnings (new ones prefixed by >>):
>>
>>    drivers/net/ethernet/freescale/fsl_pq_mdio.c: In function 'fsl_pq_mdio_remove':
>>>> drivers/net/ethernet/freescale/fsl_pq_mdio.c:498:27: warning: unused variable 'priv' [-Wunused-variable]
>>      struct fsl_pq_mdio_priv *priv = bus->priv;
>
>Humm, this looks bogus, the variable is used see below:
>
>>                               ^~~~
>>
>> vim +/priv +498 drivers/net/ethernet/freescale/fsl_pq_mdio.c
>>
>> 1577ecef drivers/net/fsl_pq_mdio.c                    Andy Fleming    2009-02-04  482  	return 0;
>> 1577ecef drivers/net/fsl_pq_mdio.c                    Andy Fleming    2009-02-04  483
>> dd3b8a32 drivers/net/ethernet/freescale/fsl_pq_mdio.c Timur Tabi      2012-08-29  484  error:
>> dd3b8a32 drivers/net/ethernet/freescale/fsl_pq_mdio.c Timur Tabi      2012-08-29  485  	if (priv->map)
>> b3319b10 drivers/net/fsl_pq_mdio.c                    Anton Vorontsov 2009-12-30  486  		iounmap(priv->map);
>> dd3b8a32 drivers/net/ethernet/freescale/fsl_pq_mdio.c Timur Tabi      2012-08-29  487
>> 1577ecef drivers/net/fsl_pq_mdio.c                    Andy Fleming    2009-02-04  488  	kfree(new_bus);
>> dd3b8a32 drivers/net/ethernet/freescale/fsl_pq_mdio.c Timur Tabi      2012-08-29  489
>> 1577ecef drivers/net/fsl_pq_mdio.c                    Andy Fleming    2009-02-04  490  	return err;
>> 1577ecef drivers/net/fsl_pq_mdio.c                    Andy Fleming    2009-02-04  491  }
>> 1577ecef drivers/net/fsl_pq_mdio.c                    Andy Fleming    2009-02-04  492
>> 1577ecef drivers/net/fsl_pq_mdio.c                    Andy Fleming    2009-02-04  493
>> 5078ac79 drivers/net/ethernet/freescale/fsl_pq_mdio.c Timur Tabi      2012-08-29  494  static int fsl_pq_mdio_remove(struct platform_device *pdev)
>> 1577ecef drivers/net/fsl_pq_mdio.c                    Andy Fleming    2009-02-04  495  {
>> 5078ac79 drivers/net/ethernet/freescale/fsl_pq_mdio.c Timur Tabi      2012-08-29  496  	struct device *device = &pdev->dev;
>> 1577ecef drivers/net/fsl_pq_mdio.c                    Andy Fleming    2009-02-04  497  	struct mii_bus *bus = dev_get_drvdata(device);
>> b3319b10 drivers/net/fsl_pq_mdio.c                    Anton Vorontsov 2009-12-30 @498  	struct fsl_pq_mdio_priv *priv = bus->priv;
>> 1577ecef drivers/net/fsl_pq_mdio.c                    Andy Fleming    2009-02-04  499
>> 1577ecef drivers/net/fsl_pq_mdio.c                    Andy Fleming    2009-02-04  500  	mdiobus_unregister(bus);
>> 1577ecef drivers/net/fsl_pq_mdio.c                    Andy Fleming    2009-02-04  501
>> b3319b10 drivers/net/fsl_pq_mdio.c                    Anton Vorontsov 2009-12-30  502  	iounmap(priv->map);
>
>Right here.
>
>What compiler version is this?

Compiler is sh4-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705.

include/asm-generic/io.h conditionally defines iounmap() to be an
empty inline function, which may explain the warning on sh4.

General speaking, it's a false warning. The solution could be to teach
the robot to ignore such 'unused variable' warnings in non-x86 archs.

Thanks,
Fengguang
