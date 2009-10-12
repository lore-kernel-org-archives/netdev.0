From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH] acenic: Pass up error code from ace_load_firmware()
Date: Mon, 12 Oct 2009 02:34:46 +0100
Message-ID: <1255311286.2488.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Jes Sorensen <jes@trained-monkey.org>, linux-acenic@sunsite.dk,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46753 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752247AbZJLBf2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Oct 2009 21:35:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If ace_load_firmware() fails, ace_init() cleans up but still returns
0, leading to an oops as seen in <http://bugs.debian.org/521383>.
It should pass the error code up.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Cc: stable@kernel.org
---
Compile-tested only.

Ben.

 drivers/net/acenic.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 08419ee..12bfc44 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -1209,7 +1209,8 @@ static int __devinit ace_init(struct net_device *dev)
 	memset(ap->info, 0, sizeof(struct ace_info));
 	memset(ap->skb, 0, sizeof(struct ace_skb));
 
-	if (ace_load_firmware(dev))
+	ecode = ace_load_firmware(dev);
+	if (ecode)
 		goto init_error;
 
 	ap->fw_running = 0;
-- 
1.6.4.3


