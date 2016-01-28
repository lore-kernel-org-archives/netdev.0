From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/9] net: bgmac: clarify CONFIG_BCMA dependency
Date: Thu, 28 Jan 2016 09:49:15 +0100
Message-ID: <2754981.4bUSE7NdJb@wuerfel>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de> <1453903507-3427225-4-git-send-email-arnd@arndb.de> <20160127161110.GL8889@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>, netdev@vger.kernel.org,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	linux-kernel@vger.kernel.org,
	Rajesh Borundia <Rajesh.Borundia@qlogic.com>,
	Michael Chan <mchan@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160127161110.GL8889@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 27 January 2016 11:11:10 Paul Gortmaker wrote:
> [[PATCH 3/9] net: bgmac: clarify CONFIG_BCMA dependency] On 27/01/2016 (Wed 15:04) Arnd Bergmann wrote:
> 
> > The bgmac driver depends on BCMA_HOST_SOC, which is only used
> > when CONFIG_BCMA is enabled. However, it is a bool option and can
> > be set when CONFIG_BCMA=m, and then bgmac can be built-in, leading
> > to an obvious link error:
> > 
> > drivers/built-in.o: In function `bgmac_init':
> > :(.init.text+0x7f2c): undefined reference to `__bcma_driver_register'
> > drivers/built-in.o: In function `bgmac_exit':
> > :(.exit.text+0x110a): undefined reference to `bcma_driver_unregister'
> > 
> > To avoid this case, we need to depend on both BCMA and BCMA_SOC,
> > as this patch does. I'm also trying to make the dependency more
> > readable by splitting it into three lines, and adding a COMPILE_TEST
> > alternative so we can test-build it in all configurations that
> > support BCMA.
> 
> It wasn't immediately clear to me from the above why you added the
> select on FIXED_PHY.
> 

Right, I'll resend the patch with improved changelog. This series
is mostly patches for old and rare randconfig bugs, so I had built
thousands of configurations and fixed up everything until new warnings
or errors kept coming up. The FIXED_PHY error came up in the same
driver so I merged the two patches but did not notice how the changelog
failed to explain it.

Thanks,

	Arnd
