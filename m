From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] netem: fix cross-compiling failure
Date: Sat, 21 Jun 2008 01:51:19 -0400
Message-ID: <1214027479-31622-1-git-send-email-vapier@gentoo.org>
Cc: Bertrand Jacquin <beber@meleeweb.net>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:42478 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751325AbYFUFvV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jun 2008 01:51:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bertrand Jacquin <beber@meleeweb.net>

The programs in netem are compiled and run on the build machine, but they
use the CFLAGS that are meant for the target system and often times, these
are incompatible.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 netem/Makefile |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/netem/Makefile b/netem/Makefile
index 3732160..2d7d68b 100644
--- a/netem/Makefile
+++ b/netem/Makefile
@@ -2,6 +2,7 @@ DISTGEN = maketable normal pareto paretonormal
 DISTDATA = normal.dist pareto.dist paretonormal.dist experimental.dist
 
 HOSTCC ?= $(CC)
+CCOPTS  = $(CBUILD_CFLAGS)
 LDLIBS += -lm 
 
 all: $(DISTGEN) $(DISTDATA)
-- 
1.5.5.3

