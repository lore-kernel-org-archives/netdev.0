From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: [PATCH] rose_dev: fix memcpy-bug in rose_set_mac_address
Date: Tue, 27 Mar 2012 15:27:56 +0200
Message-ID: <4F71C05C.4040300@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50240 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754300Ab2C0NrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 09:47:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a small bug in rose_set_mac_address. If the current and new
MAC addresses match, then nothing needs to be done. However memcpy was used
instead of memcmp for comparison.

The patch is against the latest net-tree.

Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
Cc: Ralf Baechle <ralf@linux-mips.org>
---
 net/rose/rose_dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rose/rose_dev.c b/net/rose/rose_dev.c
index 178ff4f..3c5ce5e 100644
--- a/net/rose/rose_dev.c
+++ b/net/rose/rose_dev.c
@@ -96,7 +96,7 @@ static int rose_set_mac_address(struct net_device *dev, void *addr)
 	struct sockaddr *sa = addr;
 	int err;
 
-	if (!memcpy(dev->dev_addr, sa->sa_data, dev->addr_len))
+	if (!memcmp(dev->dev_addr, sa->sa_data, dev->addr_len))
 		return 0;
 
 	if (dev->flags & IFF_UP) {
