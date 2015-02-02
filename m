From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH net-next] drivers: net: cpsw: make cpsw_ale.c a module to
 allow re-use on Keystone
Date: Mon, 2 Feb 2015 08:40:33 -0800
Message-ID: <20150202164032.GA9418@atomide.com>
References: <1422573351-5603-1-git-send-email-m-karicheri2@ti.com>
 <1422573351-5603-2-git-send-email-m-karicheri2@ti.com>
 <1802322.NDR3d5ZRSA@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Murali Karicheri <m-karicheri2@ti.com>, w-kwok2@ti.com,
	davem@davemloft.net, mugunthanvnm@ti.com,
	prabhakar.csengg@gmail.com, grygorii.strashko@ti.com,
	lokeshvutla@ti.com, mpa@pengutronix.de,
	lsorense@csclub.uwaterloo.ca, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1802322.NDR3d5ZRSA@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Arnd Bergmann <arnd@arndb.de> [150129 15:51]:
> On Thursday 29 January 2015 18:15:51 Murali Karicheri wrote:
> > NetCP on Keystone has cpsw ale function similar to other TI SoCs
> > and this driver is re-used. To allow both ti cpsw and keystone netcp
> > to re-use the driver, convert the cpsw ale to a module and configure
> > it through Kconfig option CONFIG_TI_CPSW_ALE. Currently it is statically
> > linked to both TI CPSW and NetCP and this causes issues when the above
> > drivers are built as dynamic modules. This patch addresses this issue
> > 
> > While at it, fix the Makefile and code to build both netcp_core and
> > netcp_ethss as dynamic modules. This is needed to support arm allmodconfig.
> > This also requires exporting of API calls provided by netcp_core so that
> > both the above can be dynamic modules.
> > 
> > Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
> > ---
> >  drivers/net/ethernet/ti/Kconfig       |   19 +++++++++++++++++--
> >  drivers/net/ethernet/ti/Makefile      |    8 +++++---
> >  drivers/net/ethernet/ti/cpsw_ale.c    |   26 ++++++++++++++++++++++++--
> >  drivers/net/ethernet/ti/netcp_core.c  |    8 ++++++++
> >  drivers/net/ethernet/ti/netcp_ethss.c |    5 +++++
> >  5 files changed, 59 insertions(+), 7 deletions(-)
> 
> I was hoping there would be a way without exporting all those symbols, but
> I also couldn't come up with a better solution. I'm putting this into the
> randconfig build test for now, but I'm guessing it's fine.

Probably the best way in the long run is to add a single exported
function to cpsw-common.c I just added for the MAC address function.

Then all the cpsw like drivers can register with that instead of
having tons of custom exported functions.

But before doing that, we should have a clear idea what all can
be shared. Murali, maybe you can take a look at that?

Regards,

Tony
