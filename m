From: David Decotigny <ddecotig@gmail.com>
Subject: Re: [PATCH net-next v4 12/19] net: fcoe: use __ethtool_get_ksettings
Date: Wed, 9 Dec 2015 20:01:24 -0800
Message-ID: <CAG88wWZP7KGC5zguP0te7KaLngLX98Q2ZsDJmbU-GHEEaLzKtA@mail.gmail.com>
References: <1449683969-7305-13-git-send-email-ddecotig@gmail.com> <201512100349.fX57FR9Z%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
	linux-mips@linux-mips.org, fcoe-devel@open-fcoe.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>, Eric Dumazet <edumazet@google.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@emulex.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ed Swierk <eswierk@skyportsystems.com>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bo
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201512100349.fX57FR9Z%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

apologies, forgot to make allyesconfig/allmodconfig this time. Fixed
in my local copy. Will be part of v5 after other feedback on this v4.

On Wed, Dec 9, 2015 at 11:18 AM, kbuild test robot <lkp@intel.com> wrote:
> Hi David,
>
> [auto build test ERROR on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/David-Decotigny/RFC-new-ETHTOOL_GSETTINGS-SSETTINGS-API/20151210-022123
> config: i386-randconfig-b0-12100240 (attached as .config)
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386
>
> All errors (new ones prefixed by >>):
>
>    drivers/scsi/fcoe/fcoe_transport.c: In function 'fcoe_link_speed_update':
>>> drivers/scsi/fcoe/fcoe_transport.c:104:32: error: request for member 'mask' in something not a structure or union
>       if (ecmd.link_modes.supported.mask[0] & (
>                                    ^
>    drivers/scsi/fcoe/fcoe_transport.c:110:32: error: request for member 'mask' in something not a structure or union
>       if (ecmd.link_modes.supported.mask[0] & (
>                                    ^
>    drivers/scsi/fcoe/fcoe_transport.c:117:32: error: request for member 'mask' in something not a structure or union
>       if (ecmd.link_modes.supported.mask[0] & (
>                                    ^
>    drivers/scsi/fcoe/fcoe_transport.c:122:32: error: request for member 'mask' in something not a structure or union
>       if (ecmd.link_modes.supported.mask[0] & (
>                                    ^
>
> vim +/mask +104 drivers/scsi/fcoe/fcoe_transport.c
>
>     98          if (!__ethtool_get_ksettings(netdev, &ecmd)) {
>     99                  lport->link_supported_speeds &= ~(FC_PORTSPEED_1GBIT  |
>    100                                                    FC_PORTSPEED_10GBIT |
>    101                                                    FC_PORTSPEED_20GBIT |
>    102                                                    FC_PORTSPEED_40GBIT);
>    103
>  > 104                  if (ecmd.link_modes.supported.mask[0] & (
>    105                              SUPPORTED_1000baseT_Half |
>    106                              SUPPORTED_1000baseT_Full |
>    107                              SUPPORTED_1000baseKX_Full))
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
