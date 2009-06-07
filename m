From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 3/4] isdn: prevent NULL ptr Oops in capi_cmsg2str()
Date: Sun,  7 Jun 2009 21:09:24 +0200 (CEST)
Message-ID: <20090607-patch-03.tilman@imap.cc>
References: <20090607-patch-00.tilman@imap.cc>
To: davem@davemloft.net, Karsten Keil <karsten-keil@t-online.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-ker
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:43714 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753397AbZFGTJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Jun 2009 15:09:35 -0400
In-Reply-To: <20090607-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dereferencing of the private pointer cmsg->m in capi_cmsg2str() may
cause an Oops in case of an error, which is particularly inconvenient
as that function is typically used to format an error message. Add a
NULL pointer check to avoid this.

Impact: error handling improvement
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/capiutil.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/capi/capiutil.c b/drivers/isdn/capi/capiutil.c
index c7c2902..16f2e46 100644
--- a/drivers/isdn/capi/capiutil.c
+++ b/drivers/isdn/capi/capiutil.c
@@ -989,6 +989,8 @@ _cdebbuf *capi_cmsg2str(_cmsg * cmsg)
 {
 	_cdebbuf *cdb;
 
+	if (!cmsg->m)
+		return NULL;	/* no message */
 	cdb = cdebbuf_alloc();
 	if (!cdb)
 		return NULL;
-- 
1.6.2.1.214.ge986c

