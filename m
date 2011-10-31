From: akpm@linux-foundation.org
Subject: [patch 1/1] drivers/net/ethernet/i825xx/3c505.c: fix build with dynamic debug
Date: Mon, 31 Oct 2011 12:54:09 -0700
Message-ID: <201110311954.p9VJs9VO002313@hpaq3.eem.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, akpm@google.com,
	jbaron@redhat.com, philb@gnu.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:9160 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579Ab1JaTyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2011 15:54:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@google.com>
Subject: drivers/net/ethernet/i825xx/3c505.c: fix build with dynamic debug

The `#define filename' screws up the expansion of
DEFINE_DYNAMIC_DEBUG_METADATA:

drivers/net/ethernet/i825xx/3c505.c: In function 'send_pcb':
drivers/net/ethernet/i825xx/3c505.c:390: error: expected identifier before string constant
drivers/net/ethernet/i825xx/3c505.c:390: error: expected '}' before '.' token
drivers/net/ethernet/i825xx/3c505.c:436: error: expected identifier before string constant
drivers/net/ethernet/i825xx/3c505.c:435: error: expected '}' before '.' token
drivers/net/ethernet/i825xx/3c505.c: In function 'start_receive':
drivers/net/ethernet/i825xx/3c505.c:557: error: expected identifier before string constant
drivers/net/ethernet/i825xx/3c505.c:557: error: expected '}' before '.' token
drivers/net/ethernet/i825xx/3c505.c: In function 'receive_packet':
drivers/net/ethernet/i825xx/3c505.c:629: error: expected identifier before string constant

etc

So remove that #define and "open-code" it.

Cc: Philip Blundell <philb@gnu.org>
Cc: David Miller <davem@davemloft.net>
Cc: Jason Baron <jbaron@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ethernet/i825xx/3c505.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff -puN drivers/net/ethernet/i825xx/3c505.c~drivers-net-ethernet-i825xx-3c505c-fix-build-with-dynamic-debug drivers/net/ethernet/i825xx/3c505.c
--- a/drivers/net/ethernet/i825xx/3c505.c~drivers-net-ethernet-i825xx-3c505c-fix-build-with-dynamic-debug
+++ a/drivers/net/ethernet/i825xx/3c505.c
@@ -126,15 +126,13 @@
  *
  *********************************************************/
 
-#define filename __FILE__
-
 #define timeout_msg "*** timeout at %s:%s (line %d) ***\n"
 #define TIMEOUT_MSG(lineno) \
-	pr_notice(timeout_msg, filename, __func__, (lineno))
+	pr_notice(timeout_msg, __FILE__, __func__, (lineno))
 
 #define invalid_pcb_msg "*** invalid pcb length %d at %s:%s (line %d) ***\n"
 #define INVALID_PCB_MSG(len) \
-	pr_notice(invalid_pcb_msg, (len), filename, __func__, __LINE__)
+	pr_notice(invalid_pcb_msg, (len), __FILE__, __func__, __LINE__)
 
 #define search_msg "%s: Looking for 3c505 adapter at address %#x..."
 
_
