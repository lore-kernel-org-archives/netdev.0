From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v2 3/3] net: marvell: Allow drivers to be built with COMPILE_TEST
Date: Thu, 17 Nov 2016 10:12:00 +0100
Message-ID: <19888267.TNEXR1Cft3@wuerfel>
References: <201611171559.suMIPVBq%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, kbuild-all@01.org,
        netdev@vger.kernel.org, davem@davemloft.net, mw@semihalf.com,
        gregory.clement@free-electrons.com, Shaohui.Xie@freescale.com
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:56479 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbcKQJMy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 04:12:54 -0500
In-Reply-To: <201611171559.suMIPVBq%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, November 17, 2016 3:10:10 PM CET kbuild test robot wrote:
> url:    https://github.com/0day-ci/linux/commits/Florian-Fainelli/net-fsl-Allow-most-drivers-to-be-built-with-COMPILE_TEST/20161116-094841
> config: mips-allyesconfig (attached as .config)
> compiler: mips-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=mips 
> 
> All errors (new ones prefixed by >>):
> 
>    drivers/built-in.o: In function `mvneta_bm_pool_create':
> >> mvneta_bm.c:(.text+0x772f0c): undefined reference to `mvebu_mbus_get_dram_win_info'

We should fix this, I'd suggest either adding an inline wrapper for
mvebu_mbus_get_dram_win_info() when CONFIG_MVEBU_MBUS is not set,
or allowing CONFIG_MVEBU_MBUS to be enabled for COMPILE_TEST as well.

	Arnd
