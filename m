From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] snmp: fix SNMP_ADD_STATS()
Date: Wed, 23 Jun 2010 12:32:03 +0200
Message-ID: <1277289123.2469.278.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:41093 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab0FWKcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 06:32:08 -0400
Received: by wwc33 with SMTP id 33so860336wwc.19
        for <netdev@vger.kernel.org>; Wed, 23 Jun 2010 03:32:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit aa2ea0586d9d (tcp: fix outsegs stat for TSO segments) incorrectly
assumed SNMP_ADD_STATS() was used from BH context.

Fix this using mib[!in_softirq()] instead of mib[0]

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Tom Herbert <therbert@google.com>
---
 include/net/snmp.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/snmp.h b/include/net/snmp.h
index 92456f1..899003d 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -134,7 +134,7 @@ struct linux_xfrm_mib {
 #define SNMP_ADD_STATS_USER(mib, field, addend)	\
 			this_cpu_add(mib[1]->mibs[field], addend)
 #define SNMP_ADD_STATS(mib, field, addend)	\
-			this_cpu_add(mib[0]->mibs[field], addend)
+			this_cpu_add(mib[!in_softirq()]->mibs[field], addend)
 /*
  * Use "__typeof__(*mib[0]) *ptr" instead of "__typeof__(mib[0]) ptr"
  * to make @ptr a non-percpu pointer.


