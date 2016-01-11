From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [PATCH] [net] phy: micrel: Fix build failure in ksz9031_config_init()
Date: Mon, 11 Jan 2016 10:23:40 +0100
Message-ID: <CA+icZUX-1HUsopevnyD+VCtcuV8cDTyJ8bSvZtHX2QfUGDw+=g@mail.gmail.com>
References: <1452340757-29507-1-git-send-email-sedat.dilek@gmail.com>
	<201601101922.K4rPhj8d%fengguang.wu@intel.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, Roosen Henri <Henri.Roosen@ginzinger.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Daney <david.daney@cavium.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <201601101922.K4rPhj8d%fengguang.wu@intel.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 10, 2016 at 12:50 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Sedat,
>
> [auto build test ERROR on net/master]
> [cannot apply to net-next/master v4.4-rc8 next-20160108]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
>

Hi,

Andrew Lunn explained when this build-failure happens in [1].
Short answer: When you merge net.git with net-next.git.

Steven posted and added the same fix for his latest next-20160111 tree
(see [2]).
Dave ACKed it in [3].

- Sedat -

[0] http://marc.info/?l=linux-netdev&m=145235493501557&w=2
[1] http://marc.info/?l=linux-netdev&m=145248039325668&w=2
[3] http://marc.info/?l=linux-netdev&m=145248135925825&w=2

> url:    https://github.com/0day-ci/linux/commits/Sedat-Dilek/phy-micrel-Fix-build-failure-in-ksz9031_config_init/20160109-200009
> config: x86_64-rhel (attached as .config)
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
>    drivers/net/phy/micrel.c: In function 'ksz9031_config_init':
>>> drivers/net/phy/micrel.c:479:22: error: 'struct phy_device' has no member named 'mdio'
>      dev_walker = &phydev->mdio.dev;
>                          ^
>
> vim +479 drivers/net/phy/micrel.c
>
>    473          const struct device *dev_walker;
>    474
>    475          /* The Micrel driver has a deprecated option to place phy OF
>    476           * properties in the MAC node. Walk up the tree of devices to
>    477           * find a device with an OF node.
>    478           */
>  > 479          dev_walker = &phydev->mdio.dev;
>    480          do {
>    481                  of_node = dev_walker->of_node;
>    482                  dev_walker = dev_walker->parent;
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
