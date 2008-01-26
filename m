From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] hamradio: fix dmascc section mismatch
Date: Fri, 25 Jan 2008 16:35:34 -0800
Message-ID: <20080125163534.5f563a10.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, klaus.kudielka@gmx.net,
	akpm <akpm@linux-foundation.org>, samr <sam@ravnborg.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:60304 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbYAZAgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 19:36:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

cc: Klaus Kudielka <klaus.kudielka@gmx.net>

hw[] is used in both init and exit functions so it cannot be initdata
(section mismatch is when CONFIG_MODULES=n and CONFIG_DMASCC=y).

WARNING: vmlinux.o(.exit.text+0xba7): Section mismatch: reference to .init.data: (between 'dmascc_exit' and 'sixpack_exit_driver')

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/hamradio/dmascc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2624-bld.orig/drivers/net/hamradio/dmascc.c
+++ linux-2624-bld/drivers/net/hamradio/dmascc.c
@@ -262,8 +262,8 @@ static void tm_isr(struct scc_priv *priv
 
 static int io[MAX_NUM_DEVS] __initdata = { 0, };
 
-/* Beware! hw[] is also used in cleanup_module(). */
-static struct scc_hardware hw[NUM_TYPES] __initdata_or_module = HARDWARE;
+/* Beware! hw[] is also used in dmascc_exit(). */
+static struct scc_hardware hw[NUM_TYPES] = HARDWARE;
 
 
 /* Global variables */
