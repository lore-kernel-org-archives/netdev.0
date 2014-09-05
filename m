From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH] iproute2 tests: Fix problem with test running
Date: Fri,  5 Sep 2014 19:46:31 +0300
Message-ID: <1409935591-30145-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:59024 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756AbaIEQyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 12:54:31 -0400
Received: by mail-lb0-f170.google.com with SMTP id w7so14056656lbi.29
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 09:54:29 -0700 (PDT)
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
index 2a4e0ba..6f2ea85 100644
--- a/testsuite/Makefile
+++ b/testsuite/Makefile
@@ -1,6 +1,7 @@
 ## -- Config --
 DEV := lo
 PREFIX := sudo
+RESULTS_DIR := "results"
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
-		TC="$$i/tc/tc" IP="$$i/ip/ip" DEV="$(DEV)" IPVER="$@" SNAME="$$i" \
-		ERRF="results/$@.$$o.err" $(KENV) $(PREFIX) tests/$@ > results/$@.$$o.out; \
+		$(PREFIX) TC="$$i/tc/tc" IP="$$i/ip/ip" DEV="$(DEV)" IPVER="$@" SNAME="$$i" \
+		ERRF="$(RESULTS_DIR)/$@.$$o.err" $(KENV) tests/$@ > $(RESULTS_DIR)/$@.$$o.out; \
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
