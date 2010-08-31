From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Tue, 31 Aug 2010 08:08:06 -0700
Message-ID: <4C7D1AD6.3080005@oracle.com>
References: <4C763A67.5040107@dsn.okisemi.com> <4C7D0E7A.5060309@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Sam Ravnborg <sam@ravnborg.org>, Joe Perches <joe@perches.com>,
	LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C7D0E7A.5060309@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/31/10 07:15, Masayuki Ohtake wrote:
> 
> Hi Sam, Joe and Stephen
> 
> Thank you for your comments.
> We have modified this driver for your comment.
> 
> ---
> Gigabit Ethernet driver of Topcliff PCH
> Patch created against 2.6.35
> 
> Topcliff PCH is the platform controller hub that is going to be used in
> Intel's upcoming general embedded platform. All IO peripherals in
> Topcliff PCH are actually devices sitting on AMBA bus. 
> Topcliff PCH has Gigabit Ethernet I/F. Using this I/F, it is able to 
> access system devices connected to Gigabit Ethernet.
> 
> Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
> ---
>  drivers/net/Kconfig                   |   10 +
>  drivers/net/Makefile                  |    1 +
>  drivers/net/pch_gbe/Makefile          |    4 +
>  drivers/net/pch_gbe/pch_gbe.h         |  683 +++++++++
>  drivers/net/pch_gbe/pch_gbe_api.c     |  246 ++++
>  drivers/net/pch_gbe/pch_gbe_api.h     |   34 +
>  drivers/net/pch_gbe/pch_gbe_ethtool.c |  618 ++++++++
>  drivers/net/pch_gbe/pch_gbe_main.c    | 2591 +++++++++++++++++++++++++++++++++
>  drivers/net/pch_gbe/pch_gbe_param.c   |  519 +++++++
>  drivers/net/pch_gbe/pch_gbe_phy.c     |  276 ++++
>  drivers/net/pch_gbe/pch_gbe_phy.h     |   35 +
>  11 files changed, 5017 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/pch_gbe/Makefile
>  create mode 100644 drivers/net/pch_gbe/pch_gbe.h
>  create mode 100644 drivers/net/pch_gbe/pch_gbe_api.c
>  create mode 100644 drivers/net/pch_gbe/pch_gbe_api.h
>  create mode 100644 drivers/net/pch_gbe/pch_gbe_ethtool.c
>  create mode 100644 drivers/net/pch_gbe/pch_gbe_main.c
>  create mode 100644 drivers/net/pch_gbe/pch_gbe_param.c
>  create mode 100644 drivers/net/pch_gbe/pch_gbe_phy.c
>  create mode 100644 drivers/net/pch_gbe/pch_gbe_phy.h
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 2decc59..f8102de 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2004,6 +2004,16 @@ menuconfig NETDEV_1000
>  	  If you say N, all options in this submenu will be skipped and disabled.
>  
>  if NETDEV_1000
> +config PCH_GBE
> +	tristate "PCH Gigabit Ethernet"
> +	depends on PCI

IMO it's not nice to list this driver before others that are already there.

> +	---help---
> +	  This is an gigabit ethernet driver for Topcliff PCH.

	  This is a gigabit

You aren't going to modify this text after the product is released, are you?
Might as well make it better now:

> +	  Topcliff PCH is the platform controller hub that is going to be used

	  Topcliff PCH is the platform controller hub that is used in Intel's
	  general embedded platform.
> +	  in Intel's upcoming general embedded platform.
> +	  Topcliff PCH has Gigabit Ethernet I/F. Using this I/F, it is able to

	Change "I/F" to "interface".

> +	  access system devices connected to Gigabit Ethernet.
> +	  This driver enables Gigabit Ethernet function.
>  
>  config ACENIC
>  	tristate "Alteon AceNIC/3Com 3C985/NetGear GA620 Gigabit support"


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
