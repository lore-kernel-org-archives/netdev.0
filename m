From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 3/9] net: bgmac: clarify CONFIG_BCMA dependency
Date: Wed, 27 Jan 2016 11:11:10 -0500
Message-ID: <20160127161110.GL8889@windriver.com>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
 <1453903507-3427225-4-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Rajesh Borundia <Rajesh.Borundia@qlogic.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	<linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.windriver.com ([192.103.53.11]:35621 "EHLO mail5.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932317AbcA0QLz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 11:11:55 -0500
Content-Disposition: inline
In-Reply-To: <1453903507-3427225-4-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[[PATCH 3/9] net: bgmac: clarify CONFIG_BCMA dependency] On 27/01/2016 (Wed 15:04) Arnd Bergmann wrote:

> The bgmac driver depends on BCMA_HOST_SOC, which is only used
> when CONFIG_BCMA is enabled. However, it is a bool option and can
> be set when CONFIG_BCMA=m, and then bgmac can be built-in, leading
> to an obvious link error:
> 
> drivers/built-in.o: In function `bgmac_init':
> :(.init.text+0x7f2c): undefined reference to `__bcma_driver_register'
> drivers/built-in.o: In function `bgmac_exit':
> :(.exit.text+0x110a): undefined reference to `bcma_driver_unregister'
> 
> To avoid this case, we need to depend on both BCMA and BCMA_SOC,
> as this patch does. I'm also trying to make the dependency more
> readable by splitting it into three lines, and adding a COMPILE_TEST
> alternative so we can test-build it in all configurations that
> support BCMA.

It wasn't immediately clear to me from the above why you added the
select on FIXED_PHY.

P.
