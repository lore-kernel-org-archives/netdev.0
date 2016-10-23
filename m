From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] doc: update docbook annotations for socket and skb
Date: Sun, 23 Oct 2016 09:28:29 -0700
Message-ID: <20161023092829.3c2bc1f2@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34749 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752171AbcJWQ2O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 12:28:14 -0400
Received: by mail-pf0-f177.google.com with SMTP id r16so84013555pfg.1
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2016 09:28:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Stephen Hemminger <sthemmin@microsoft.com>

The skbuff and sock structure both had missing parameter annotation
values.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 include/linux/skbuff.h | 1 +
 include/net/sock.h     | 4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 601258f..32810f2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -936,6 +936,7 @@ struct sk_buff_fclones {
 
 /**
  *	skb_fclone_busy - check if fclone is busy
+ *	@sk: socket
  *	@skb: buffer
  *
  * Returns true if skb is a fast clone, and its clone is not freed.
diff --git a/include/net/sock.h b/include/net/sock.h
index ebf75db..73c6b00 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -252,6 +252,7 @@ struct sock_common {
   *	@sk_pacing_rate: Pacing rate (if supported by transport/packet scheduler)
   *	@sk_max_pacing_rate: Maximum pacing rate (%SO_MAX_PACING_RATE)
   *	@sk_sndbuf: size of send buffer in bytes
+  *	@sk_padding: unused element for alignment
   *	@sk_no_check_tx: %SO_NO_CHECK setting, set checksum in TX packets
   *	@sk_no_check_rx: allow zero checksum in RX packets
   *	@sk_route_caps: route capabilities (e.g. %NETIF_F_TSO)
@@ -302,7 +303,8 @@ struct sock_common {
   *	@sk_backlog_rcv: callback to process the backlog
   *	@sk_destruct: called at sock freeing time, i.e. when all refcnt == 0
   *	@sk_reuseport_cb: reuseport group container
- */
+  *	@sk_rcu: used during RCU grace period
+  */
 struct sock {
 	/*
 	 * Now struct inet_timewait_sock also uses sock_common, so please just
-- 
2.9.3
