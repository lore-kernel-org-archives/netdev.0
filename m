From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next v1] netcp driver fixes to build as dynamic modules
Date: Fri, 30 Jan 2015 10:36:42 -0500
Message-ID: <1422632203-2531-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Murali Karicheri <m-karicheri2@ti.com>
To: <w-kwok2@ti.com>, <davem@davemloft.net>, <mugunthanvnm@ti.com>,
	<tony@atomide.com>, <prabhakar.csengg@gmail.com>,
	<grygorii.strashko@ti.com>, <lokeshvutla@ti.com>,
	<mpa@pengutronix.de>, <lsorense@csclub.uwaterloo.ca>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduce changes to netcp modules and makefile to build
the driver as dynamic modules. This also convert existing cpsw_ale.c
as a module so that it can be re-used across netcp and ti_cpsw drivers.
This also fixes the issue seen when build using arm allmodconfig
I have made an allmodconfig with this patch and the build succeeds.

 make allmodconfig
 make uImage LOADADDR=0x80008000; make modules

 After the build all of the following .ko files are seen
 
Note: need to verify this on a platform with TI CPSW.

 drivers/net/ethernet/ti/cpsw_ale.ko
 drivers/net/ethernet/ti/davinci_cpdma.ko
 drivers/net/ethernet/ti/davinci_emac.ko
 drivers/net/ethernet/ti/davinci_mdio.ko
 drivers/net/ethernet/ti/keystone_netcp_ethss.ko
 drivers/net/ethernet/ti/keystone_netcp.ko
 drivers/net/ethernet/ti/ti_cpsw.ko
 drivers/net/ethernet/ti/tlan.ko
 
 This also has dependency on the following patches for netcp :-
 [1] https://lkml.org/lkml/2015/1/28/1102
 [2] https://lkml.org/lkml/2015/1/29/881
 [3] https://lkml.org/lkml/2015/1/29/882

History:
   v1: Added Acked-by and Tested-by following:-

	Acked-by: Arnd Bergmann <arnd@arndb.de>
	Acked-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
	Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
	Tested-by: Mugunthan V N <mugunthanvnm@ti.com>


Murali Karicheri (1):
  drivers: net: cpsw: make cpsw_ale.c a module to allow re-use on
    Keystone

 drivers/net/ethernet/ti/Kconfig       |   19 +++++++++++++++++--
 drivers/net/ethernet/ti/Makefile      |    8 +++++---
 drivers/net/ethernet/ti/cpsw_ale.c    |   26 ++++++++++++++++++++++++--
 drivers/net/ethernet/ti/netcp_core.c  |    8 ++++++++
 drivers/net/ethernet/ti/netcp_ethss.c |    5 +++++
 5 files changed, 59 insertions(+), 7 deletions(-)

-- 
1.7.9.5
