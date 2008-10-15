From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [patch] rtl8102e: commit 7bf6bf480 zeroized MAC address
Date: Wed, 15 Oct 2008 14:31:57 +0200
Message-ID: <48F5E2BD.8030901@redhat.com>
References: <200810151011.m9FABBRj025271@post.webmailer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: c4p7n@capitanio.org, Francois Romieu <romieu@fr.zoreil.com>,
	kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:61000 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276AbYJOMcD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2008 08:32:03 -0400
In-Reply-To: <200810151011.m9FABBRj025271@post.webmailer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

c4p7n@capitanio.org wrote:
> Tested on top of linus tree and back ported 2.6.27.
> 
> Please cc me, thanks
> Martin Capitanio
> 
I think this one is more common.

Ivan

=====
Subject: [PATCH] [r8169] initialize MAC address found in EEPROM only if is it valid

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/r8169.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c821da2..587a96c 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1975,8 +1975,9 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
 
 	dprintk("MAC address found in EEPROM: %s\n", print_mac(buf, mac));
 
-	/* Write MAC address */
-	rtl_rar_set(tp, mac);
+	/* Write MAC address if is it valid */
+	if (is_valid_ether_addr(mac))
+		rtl_rar_set(tp, mac);
 }
 
 static int __devinit
-- 
1.5.6.3
