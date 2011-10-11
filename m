From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] cipso: remove an unneeded NULL check in cipso_v4_doi_add()
Date: Tue, 11 Oct 2011 16:22:29 +0300
Message-ID: <20111011132228.GA27127@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:56701 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754234Ab1JKNXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 09:23:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We dereference doi_def on the line before the NULL check.  It has
been this way since 2008.  I checked all the callers and doi_def is
always non-NULL here.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 2c2a98e..86f3b88 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -476,7 +476,7 @@ int cipso_v4_doi_add(struct cipso_v4_doi *doi_def,
 	doi = doi_def->doi;
 	doi_type = doi_def->type;
 
-	if (doi_def == NULL || doi_def->doi == CIPSO_V4_DOI_UNKNOWN)
+	if (doi_def->doi == CIPSO_V4_DOI_UNKNOWN)
 		goto doi_add_return;
 	for (iter = 0; iter < CIPSO_V4_TAG_MAXCNT; iter++) {
 		switch (doi_def->tags[iter]) {
