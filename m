From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH v2] iproute2 tests: Fix problem with test running
Date: Sat,  6 Sep 2014 13:27:07 +0300
Message-ID: <1409999227-16970-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:42905 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbaIFKfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 06:35:10 -0400
Received: by mail-lb0-f172.google.com with SMTP id c11so6498120lbj.31
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2014 03:35:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tests were not allowed to be ran, the following
issues were fixed:
    - creating the results folder before test running
    - sudo $PREFIX moved before variables definition which
        allow to pass them through the sudo to test script.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 testsuite/Makefile | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/testsuite/Makefile b/testsuite/Makefile
index 2a4e0ba..b4ab15e 100644
--- a/testsuite/Makefile
+++ b/testsuite/Makefile
@@ -1,6 +1,7 @@
 ## -- Config --
 DEV := lo
-PREFIX := sudo
+PREFIX := sudo -E
+RESULTS_DIR := results
 ## -- End Config --
 
 TESTS := $(patsubst tests/%,%,$(wildcard tests/*.t))
@@ -23,23 +24,24 @@ listtests:
 alltests: $(TESTS)
 
 clean:
-	@rm -rf results/*
+	@rm -rf $(RESULTS_DIR)
 
 distclean: clean
 	echo "Entering iproute2" && cd iproute2 && $(MAKE) distclean && cd ..;
 
 $(TESTS):
+	@mkdir -p $(RESULTS_DIR)
 	@for i in $(IPVERS); do \
 		o=`echo $$i | sed -e 's/iproute2\///'`; \
 		echo -n "Running $@ [$$o/`uname -r`]: "; \
 		TC="$$i/tc/tc" IP="$$i/ip/ip" DEV="$(DEV)" IPVER="$@" SNAME="$$i" \
-		ERRF="results/$@.$$o.err" $(KENV) $(PREFIX) tests/$@ > results/$@.$$o.out; \
+		ERRF="$(RESULTS_DIR)/$@.$$o.err" $(KENV) $(PREFIX) tests/$@ > $(RESULTS_DIR)/$@.$$o.out; \
 		if [ "$$?" = "127" ]; then \
 			echo "SKIPPED"; \
-		elif [ -e "results/$@.$$o.err" ]; then \
+		elif [ -e "$(RESULTS_DIR)/$@.$$o.err" ]; then \
 			echo "FAILED"; \
 		else \
 			echo "PASS"; \
 		fi; \
-		dmesg > results/$@.$$o.dmesg; \
+		dmesg > $(RESULTS_DIR)/$@.$$o.dmesg; \
 	done
-- 
2.1.0
