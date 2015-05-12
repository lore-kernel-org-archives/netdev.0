From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 1/2] tests: Run each test in network namespace
Date: Tue, 12 May 2015 17:40:15 +0300
Message-ID: <1431441616-25174-2-git-send-email-vadim4j@gmail.com>
References: <1431441616-25174-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:33050 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933120AbbELOk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 10:40:57 -0400
Received: by wgin8 with SMTP id n8so12580091wgi.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 07:40:56 -0700 (PDT)
In-Reply-To: <1431441616-25174-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Changed to forcely running each test in network
namespace to do not affect on current network setup.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 testsuite/Makefile | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/testsuite/Makefile b/testsuite/Makefile
index a2c8a2d..4b945b0 100644
--- a/testsuite/Makefile
+++ b/testsuite/Makefile
@@ -1,9 +1,11 @@
 ## -- Config --
 DEV := lo
-PREFIX := sudo -E
+PREFIX := sudo -E unshare -n
 RESULTS_DIR := results
 ## -- End Config --
 
+HAVE_UNSHARED_UTIL := $(shell unshare --version 2> /dev/null)
+
 rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
 
 TESTS := $(patsubst tests/%,%,$(call rwildcard,tests/,*.t))
@@ -38,6 +40,9 @@ distclean: clean
 	echo "Entering iproute2" && cd iproute2 && $(MAKE) distclean && cd ..;
 
 $(TESTS): clean
+ifeq (,$(HAVE_UNSHARED_UTIL))
+	$(error Please install util-linux tools to run tests in separated network namespace)
+endif
 	@mkdir -p $(RESULTS_DIR)
 	
 	@for d in $(TESTS_DIR); do \
-- 
2.3.1
