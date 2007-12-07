From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Use BUILD_BUG_ON in inet_timewait_sock.c checks
Date: Fri, 07 Dec 2007 20:46:10 +0300
Message-ID: <475986E2.6050409@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55829 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753625AbXLGRqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 12:46:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the INET_TWDR_TWKILL_SLOTS vs sizeof(twdr->thread_slots)
check nicer.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index a60b99e..d43e787 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -194,16 +194,14 @@ out:
 
 EXPORT_SYMBOL_GPL(inet_twdr_hangman);
 
-extern void twkill_slots_invalid(void);
-
 void inet_twdr_twkill_work(struct work_struct *work)
 {
 	struct inet_timewait_death_row *twdr =
 		container_of(work, struct inet_timewait_death_row, twkill_work);
 	int i;
 
-	if ((INET_TWDR_TWKILL_SLOTS - 1) > (sizeof(twdr->thread_slots) * 8))
-		twkill_slots_invalid();
+	BUILD_BUG_ON((INET_TWDR_TWKILL_SLOTS - 1) >
+			(sizeof(twdr->thread_slots) * 8));
 
 	while (twdr->thread_slots) {
 		spin_lock_bh(&twdr->death_lock);

