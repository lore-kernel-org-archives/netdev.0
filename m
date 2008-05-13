From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][PPP]: Do not free not yet unregistered net device.
Date: Tue, 13 May 2008 19:30:50 +0400
Message-ID: <4829B42A.8070005@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:57981 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761251AbYEMPd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 11:33:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An error path in ppp_create_interface() lacks one and may
BUG in free_netdev() checking for proper dev->reg_state.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index d3207c0..1f4ca2b 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -2458,6 +2458,7 @@ ppp_create_interface(int unit, int *retp)
 
 out3:
 	atomic_dec(&ppp_unit_count);
+	unregister_netdev(dev);
 out2:
 	mutex_unlock(&all_ppp_mutex);
 	free_netdev(dev);
