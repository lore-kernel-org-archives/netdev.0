From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/2] testsuite: Search kernel config in modules dir also
Date: Wed,  8 Feb 2017 00:04:22 +0100
Message-ID: <20170207230422.31936-3-phil@nwl.cc>
References: <20170207230422.31936-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35871 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751743AbdBGXF3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 18:05:29 -0500
In-Reply-To: <20170207230422.31936-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At least in Fedora there is no /proc/config.gz but instead
/lib/modules/`uname -r`/config, so use that as a fallback.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 testsuite/Makefile | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/testsuite/Makefile b/testsuite/Makefile
index 17568881b8b66..41a3afc92ae98 100644
--- a/testsuite/Makefile
+++ b/testsuite/Makefile
@@ -15,6 +15,12 @@ IPVERS := $(filter-out iproute2/Makefile,$(wildcard iproute2/*))
 
 ifneq (,$(wildcard /proc/config.gz))
 	KENV := $(shell cat /proc/config.gz | gunzip | grep ^CONFIG)
+else
+KVER := $(shell uname -r)
+KCPATH := /lib/modules/${KVER}/config
+ifneq (,$(wildcard ${KCPATH}))
+	KENV := $(shell cat ${KCPATH} | grep ^CONFIG)
+endif
 endif
 
 .PHONY: compile listtests alltests configure $(TESTS)
-- 
2.11.0
