From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] via-rhine: references __init code during resume
Date: Fri, 22 Oct 2004 11:41:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4179543F.1020407@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090704010809020703050304"
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.net, netdev@oss.sgi.com, rl@hellgate.ch
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090704010809020703050304
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


-- 
~Randy

--------------090704010809020703050304
Content-Type: text/x-patch;
 name="via_rhine_mmio.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="via_rhine_mmio.patch"


Fix __init section usage:
rhine_resume calls enable_mmio, so latter cannot be __devinit;
Error: ./drivers/net/via-rhine.o .text refers to 0000000000000925 R_X86_64_PC32     .init.text+0xfffffffffffffffc

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/net/via-rhine.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -Naurp ./drivers/net/via-rhine.c~via_rhine_mmio ./drivers/net/via-rhine.c
--- ./drivers/net/via-rhine.c~via_rhine_mmio	2004-10-18 14:55:28.000000000 -0700
+++ ./drivers/net/via-rhine.c	2004-10-22 10:10:58.928311448 -0700
@@ -627,7 +627,7 @@ static void rhine_chip_reset(struct net_
 }
 
 #ifdef USE_MMIO
-static void __devinit enable_mmio(long pioaddr, u32 quirks)
+static void enable_mmio(long pioaddr, u32 quirks)
 {
 	int n;
 	if (quirks & rqRhineI) {

--------------090704010809020703050304--
