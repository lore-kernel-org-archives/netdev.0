From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net] ptp: restore the makefile for building the test program.
Date: Wed, 22 Oct 2014 21:35:15 +0200
Message-ID: <edb4b32ca0326b648d905620d95297cef5ed9391.1414006463.git.rcochran@linutronix.de>
Cc: David Miller <davem@davemloft.net>,
	Peter Foley <pefoley2@pefoley.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:59927 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932493AbaJVTfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 15:35:36 -0400
Received: by mail-wi0-f180.google.com with SMTP id em10so146631wid.1
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 12:35:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch brings back the makefile called testptp.mk which was removed
in commit adb19fb66eee (Documentation: add makefiles for more targets).

While the idea of that commit was to improve build coverage of the
examples, the new Makefile is unable to cross compile the testptp program.
In contrast, the deleted makefile was able to do this just fine.

This patch fixes the regression by restoring the original makefile.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 Documentation/ptp/testptp.mk |   33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)
 create mode 100644 Documentation/ptp/testptp.mk

diff --git a/Documentation/ptp/testptp.mk b/Documentation/ptp/testptp.mk
new file mode 100644
index 0000000..4ef2d97
--- /dev/null
+++ b/Documentation/ptp/testptp.mk
@@ -0,0 +1,33 @@
+# PTP 1588 clock support - User space test program
+#
+# Copyright (C) 2010 OMICRON electronics GmbH
+#
+#  This program is free software; you can redistribute it and/or modify
+#  it under the terms of the GNU General Public License as published by
+#  the Free Software Foundation; either version 2 of the License, or
+#  (at your option) any later version.
+#
+#  This program is distributed in the hope that it will be useful,
+#  but WITHOUT ANY WARRANTY; without even the implied warranty of
+#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+#  GNU General Public License for more details.
+#
+#  You should have received a copy of the GNU General Public License
+#  along with this program; if not, write to the Free Software
+#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+
+CC        = $(CROSS_COMPILE)gcc
+INC       = -I$(KBUILD_OUTPUT)/usr/include
+CFLAGS    = -Wall $(INC)
+LDLIBS    = -lrt
+PROGS     = testptp
+
+all: $(PROGS)
+
+testptp: testptp.o
+
+clean:
+	rm -f testptp.o
+
+distclean: clean
+	rm -f $(PROGS)
-- 
1.7.10.4
