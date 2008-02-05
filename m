From: akpm@linux-foundation.org
Subject: [patch 1/2] hamradio: fix dmascc section mismatch
Date: Mon, 04 Feb 2008 23:45:20 -0800
Message-ID: <200802050745.m157j1qJ010297@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	randy.dunlap@oracle.com, klaus.kudielka@gmx.net, sam@ravnborg.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34256 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751097AbYBEHpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 02:45:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

hw[] is used in both init and exit functions so it cannot be initdata (section
mismatch is when CONFIG_MODULES=n and CONFIG_DMASCC=y).

WARNING: vmlinux.o(.exit.text+0xba7): Section mismatch: reference to .init.data: (between 'dmascc_exit' and 'sixpack_exit_driver')

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Klaus Kudielka <klaus.kudielka@gmx.net>
Cc: Sam Ravnborg <sam@ravnborg.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/hamradio/dmascc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/hamradio/dmascc.c~hamradio-fix-dmascc-section-mismatch drivers/net/hamradio/dmascc.c
--- a/drivers/net/hamradio/dmascc.c~hamradio-fix-dmascc-section-mismatch
+++ a/drivers/net/hamradio/dmascc.c
@@ -262,8 +262,8 @@ static void tm_isr(struct scc_priv *priv
 
 static int io[MAX_NUM_DEVS] __initdata = { 0, };
 
-/* Beware! hw[] is also used in cleanup_module(). */
-static struct scc_hardware hw[NUM_TYPES] __initdata_or_module = HARDWARE;
+/* Beware! hw[] is also used in dmascc_exit(). */
+static struct scc_hardware hw[NUM_TYPES] = HARDWARE;
 
 
 /* Global variables */
_
