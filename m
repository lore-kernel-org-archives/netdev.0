From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] tests: Check existing of /proc/config.gz before use it
Date: Tue, 30 Sep 2014 09:15:10 +0300
Message-ID: <1412057710-6038-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:44039 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbaI3GXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 02:23:41 -0400
Received: by mail-la0-f45.google.com with SMTP id q1so7895877lam.18
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 23:23:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 testsuite/Makefile | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/testsuite/Makefile b/testsuite/Makefile
index b4ab15e..d1bf359 100644
--- a/testsuite/Makefile
+++ b/testsuite/Makefile
@@ -6,7 +6,10 @@ RESULTS_DIR := results
 
 TESTS := $(patsubst tests/%,%,$(wildcard tests/*.t))
 IPVERS := $(filter-out iproute2/Makefile,$(wildcard iproute2/*))
-KENV := $(shell cat /proc/config.gz | gunzip | grep ^CONFIG)
+
+ifneq (,$(wildcard /proc/config.gz))
+	KENV := $(shell cat /proc/config.gz | gunzip | grep ^CONFIG)
+endif
 
 .PHONY: compile listtests alltests configure $(TESTS)
 
-- 
2.1.0
