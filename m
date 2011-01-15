From: Dan Carpenter <error27@gmail.com>
Subject: [patch] 9p: fix min_t() casting
Date: Sat, 15 Jan 2011 23:35:39 +0300
Message-ID: <20110115203539.GF2721@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Sripathi Kodi <sripathik@in.ibm.com>,
	Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56806 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789Ab1AOUgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jan 2011 15:36:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The intent here was to cap the length to USHRT_MAX, but what the
code actually does is it just casts the return from strlen() to
unsigned short and truncates the significant bits away.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/9p/protocol.c b/net/9p/protocol.c
index 1e308f2..0422581 100644
--- a/net/9p/protocol.c
+++ b/net/9p/protocol.c
@@ -403,7 +403,7 @@ p9pdu_vwritef(struct p9_fcall *pdu, int proto_version, const char *fmt,
 				const char *sptr = va_arg(ap, const char *);
 				uint16_t len = 0;
 				if (sptr)
-					len = min_t(uint16_t, strlen(sptr),
+					len = min_t(size_t, strlen(sptr),
 								USHRT_MAX);
 
 				errcode = p9pdu_writef(pdu, proto_version,
