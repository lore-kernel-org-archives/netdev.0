From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tlan: restore deleted module parameters.
Date: Wed, 4 May 2005 15:33:11 -0700
Message-ID: <20050504153311.7d1a0fe9@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.58.0504241751090.13938@lea.ulyssis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefaan De Roeck <stefaan@ulyssis.org>, Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <Pine.LNX.4.58.0504241751090.13938@lea.ulyssis.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The module parameter values got lost in the conversion to the new module_param
interface. This should fix it.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Index: tlan/drivers/net/tlan.c
===================================================================
--- tlan.orig/drivers/net/tlan.c
+++ tlan/drivers/net/tlan.c
@@ -193,6 +193,12 @@ static  int aui[MAX_TLAN_BOARDS];
 static  int duplex[MAX_TLAN_BOARDS];
 static  int speed[MAX_TLAN_BOARDS];
 static  int boards_found;
+module_param_array(aui, int, NULL, 0);
+module_param_array(duplex, int, NULL, 0);
+module_param_array(speed, int, NULL, 0);
+MODULE_PARM_DESC(aui, "ThunderLAN use AUI port(s) (0-1)");
+MODULE_PARM_DESC(duplex, "ThunderLAN duplex setting(s) (0-default, 1-half, 2-full)");
+MODULE_PARM_DESC(speed, "ThunderLAN port speen setting(s) (0,10,100)");
 
 MODULE_AUTHOR("Maintainer: Samuel Chessman <chessman@tux.org>");
 MODULE_DESCRIPTION("Driver for TI ThunderLAN based ethernet PCI adapters");
@@ -204,8 +210,13 @@ MODULE_LICENSE("GPL");
 
 /* Turn on debugging. See Documentation/networking/tlan.txt for details */
 static  int		debug;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "ThunderLAN debug mask");
 
 static	int		bbuf;
+module_param(bbuf, int, 0);
+MODULE_PARM_DESC(bbuf, "ThunderLAN use big buffer (0-1)");
+
 static	u8		*TLanPadBuffer;
 static  dma_addr_t	TLanPadBufferDMA;
 static	char		TLanSignature[] = "TLAN";
