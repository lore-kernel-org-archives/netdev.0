From: =?UTF-8?q?Asbj=C3=B8rn=20Sloth=20T=C3=B8nnesen?=
        <asbjorn@asbjorn.st>
Subject: [PATCH iproute2 1/2] testsuite: refactor kernel config search
Date: Wed, 15 Feb 2017 21:26:41 +0000
Message-ID: <20170215212642.10131-1-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        =?UTF-8?q?Asbj=C3=B8rn=20Sloth=20T=C3=B8nnesen?=
        <asbjorn@asbjorn.st>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([185.38.24.25]:48100 "EHLO mail.asbjorn.biz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750719AbdBOVfW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 16:35:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Asbjørn Sloth Tønnesen <asbjorn@asbjorn.st>
---
 testsuite/Makefile | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/testsuite/Makefile b/testsuite/Makefile
index 50a7bafa..fc693368 100644
--- a/testsuite/Makefile
+++ b/testsuite/Makefile
@@ -17,8 +17,9 @@ ifneq (,$(wildcard /proc/config.gz))
 	KENV := $(shell cat /proc/config.gz | gunzip | grep ^CONFIG)
 else
 KVER := $(shell uname -r)
-KCPATH := /lib/modules/${KVER}/config
-ifneq (,$(wildcard ${KCPATH}))
+KCPATHS := /lib/modules/$(KVER)/config
+KCPATH := $(firstword $(wildcard $(KCPATHS)))
+ifneq (,$(KCPATH))
 	KENV := $(shell cat ${KCPATH} | grep ^CONFIG)
 endif
 endif
-- 
2.11.0
