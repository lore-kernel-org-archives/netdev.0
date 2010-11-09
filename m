From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH v2] Prevent reading uninitialized memory with socket filters
Date: Tue, 09 Nov 2010 18:53:37 -0500
Message-ID: <1289346817.7380.16.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: security@kernel.org, stable@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:55949 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166Ab0KIXxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 18:53:40 -0500
Received: from unknown (HELO [172.28.170.78]) (drosenbe@[206.205.176.2])
          (envelope-sender <drosenberg@vsecurity.com>)
          by mx1.vsecurity.com (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 9 Nov 2010 23:53:38 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As requested, avoiding the memset.

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

diff -urp a/net/core/filter.c b/net/core/filter.c
--- a/net/core/filter.c	2010-11-08 22:10:26.820703471 -0500
+++ b/net/core/filter.c	2010-11-09 18:49:33.857201963 -0500
@@ -116,7 +116,7 @@ unsigned int sk_run_filter(struct sk_buf
 	void *ptr;
 	u32 A = 0;			/* Accumulator */
 	u32 X = 0;			/* Index Register */
-	u32 mem[BPF_MEMWORDS];		/* Scratch Memory Store */
+	u32 mem[BPF_MEMWORDS] = {};	/* Scratch Memory Store */
 	u32 tmp;
 	int k;
 	int pc;


