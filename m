From: Huzaifa Sidhpurwala <huzaifas@redhat.com>
Subject: [PATCH] Check the value of doi before referencing it
Date: Wed, 18 May 2011 09:59:40 +0530
Message-ID: <1305692980-4730-1-git-send-email-huzaifas@redhat.com>
Cc: kaber@trash.net, yoshfuji@linux-ipv6.org, jmorris@namei.org,
	pekkas@netcore.fi, kuznet@ms2.inr.ac.ru, davem@davemloft.net,
	Huzaifa Sidhpurwala <huzaifas@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39692 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751058Ab1EREag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2011 00:30:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Value of doi is not checked before referencing it.
Though this does not cause any null pointer dereference since
all the callers of cipso_v4_doi_add check the value of doi
before calling the function, but it would be a good programming
practice to do so anyways :)

Signed-off-by: Huzaifa Sidhpurwala <huzaifas@redhat.com>
---
 net/ipv4/cipso_ipv4.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index a0af7ea..7adc4ea 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -473,10 +473,13 @@ int cipso_v4_doi_add(struct cipso_v4_doi *doi_def,
 	u32 doi_type;
 	struct audit_buffer *audit_buf;
 
-	doi = doi_def->doi;
-	doi_type = doi_def->type;
+	if (doi_def) {
+		doi = doi_def->doi;
+		doi_type = doi_def->type;
+	} else
+	goto doi_add_return;
 
-	if (doi_def == NULL || doi_def->doi == CIPSO_V4_DOI_UNKNOWN)
+	if (doi_def->doi == CIPSO_V4_DOI_UNKNOWN)
 		goto doi_add_return;
 	for (iter = 0; iter < CIPSO_V4_TAG_MAXCNT; iter++) {
 		switch (doi_def->tags[iter]) {
-- 
1.7.1

