From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH] Prevent reading uninitialized memory with socket filters
Date: Tue, 09 Nov 2010 17:28:44 -0500
Message-ID: <1289341724.7380.13.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, security@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:56575 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751607Ab0KIW2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 17:28:54 -0500
Received: from unknown (HELO [172.28.170.78]) (drosenbe@[206.205.176.2])
          (envelope-sender <drosenberg@vsecurity.com>)
          by mx1.vsecurity.com (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 9 Nov 2010 22:27:43 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "mem" array used as scratch space for socket filters is not
initialized, allowing unprivileged users to leak kernel stack bytes.

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

---
 net/core/filter.c               |    2 ++
 1 file changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 7beaec3..2749ba0 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -121,6 +121,8 @@ unsigned int sk_run_filter(struct sk_buff *skb, struct sock_filter *filter, int
 	int k;
 	int pc;
 
+	memset(mem, 0, sizeof(mem));
+
 	/*
 	 * Process array of filter instructions.
 	 */


