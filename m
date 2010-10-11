From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH net-next 4/5] irda: Fix parameter extraction stack overflow
Date: Mon, 11 Oct 2010 02:25:01 +0200
Message-ID: <efc463eb508798da4243625b08c7396462cabf9f.1286756123.git.sameo@linux.intel.com>
References: <cover.1286756123.git.sameo@linux.intel.com>
Cc: netdev@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>,
	stable@kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:9991 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042Ab0JKA0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Oct 2010 20:26:08 -0400
In-Reply-To: <cover.1286756123.git.sameo@linux.intel.com>
In-Reply-To: <cover.1286756123.git.sameo@linux.intel.com>
References: <cover.1286756123.git.sameo@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: stable@kernel.org
Reported-by: Ilja Van Sprundel <ivansprundel@ioactive.com>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 net/irda/parameters.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/irda/parameters.c b/net/irda/parameters.c
index fc1a205..71cd38c 100644
--- a/net/irda/parameters.c
+++ b/net/irda/parameters.c
@@ -298,6 +298,8 @@ static int irda_extract_string(void *self, __u8 *buf, int len, __u8 pi,
 
 	p.pi = pi;     /* In case handler needs to know */
 	p.pl = buf[1]; /* Extract length of value */
+	if (p.pl > 32)
+		p.pl = 32;
 
 	IRDA_DEBUG(2, "%s(), pi=%#x, pl=%d\n", __func__,
 		   p.pi, p.pl);
@@ -318,7 +320,7 @@ static int irda_extract_string(void *self, __u8 *buf, int len, __u8 pi,
 		   (__u8) str[0], (__u8) str[1]);
 
 	/* Null terminate string */
-	str[p.pl+1] = '\0';
+	str[p.pl] = '\0';
 
 	p.pv.c = str; /* Handler will need to take a copy */
 
-- 
1.7.1

