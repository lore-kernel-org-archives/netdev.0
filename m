From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch] 2.6.1-rc1-mm1 - erroneous __devinitdata in the r8169 driver
Date: Wed, 7 Jan 2004 00:27:46 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040107002746.A7314@electric-eye.fr.zoreil.com>
References: <20031122183001.GA16993@gtf.org> <20031124000939.A456@electric-eye.fr.zoreil.com> <20031126004550.A25408@electric-eye.fr.zoreil.com> <20031127235143.A16767@electric-eye.fr.zoreil.com> <20031130014738.A2589@electric-eye.fr.zoreil.com> <3FF846C3.5070207@mainstreetsoftworks.com> <20040104233849.A3214@electric-eye.fr.zoreil.com> <20040105231741.A19514@electric-eye.fr.zoreil.com> <3FFA6981.7030006@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3V7upXqbjpZ4EhLz"
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Brad House <brad@mainstreetsoftworks.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <3FFA6981.7030006@pobox.com>; from jgarzik@pobox.com on Tue, Jan 06, 2004 at 02:53:37AM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

  more silly bug in the r8169 driver.

Brad, I would really welcome you reporting that you can
send/receive a few packets (more than 64 ?) before the driver
panics horribly in rtl8169_rx_interrupt.

I will not be reachable from tomorrow until late friday.

--
Ueimor


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-buggy-devinitdata.patch"


Do not mark __devinitdata a data which is required when network device opens.


 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/r8169.c~r8169-buggy-devinitdata drivers/net/r8169.c
--- linux-2.6.1-rc1-mm1/drivers/net/r8169.c~r8169-buggy-devinitdata	2004-01-07 00:01:50.000000000 +0100
+++ linux-2.6.1-rc1-mm1-romieu/drivers/net/r8169.c	2004-01-07 00:03:47.000000000 +0100
@@ -129,7 +129,7 @@ const static struct {
 	const char *name;
 	u8 mac_version;
 	u32 RxConfigMask;	/* Clears the bits supported by this chip */
-} rtl_chip_info[] __devinitdata = {
+} rtl_chip_info[] = {
 	_R("RTL8169",		RTL_GIGA_MAC_VER_B, 0xff7e1880),
 	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_D, 0xff7e1880),
 	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_E, 0xff7e1880)

_

--3V7upXqbjpZ4EhLz--
