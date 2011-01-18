From: holger@eitzenberger.org
Subject: [patch 4/4] ipset: fix build with NDEBUG defined
Date: Tue, 18 Jan 2011 15:21:58 +0100
Message-ID: <20110118142248.489615870@eitzenberger.org>
References: <20110118142154.697547841@eitzenberger.org>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:53188 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938Ab1AROWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 09:22:51 -0500
Content-Disposition: inline; filename=ipset-fix-NDEBUG.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The usage of the gcc option -Wunused-parameter interferes badly with
the assert() macros.  In case -DNDEBUG is specified build fails with:

  cc1: warnings being treated as errors
  print.c: In function 'ipset_print_family':
  print.c:92: error: unused parameter 'opt'
  print.c: In function 'ipset_print_port':
  print.c:413: error: unused parameter 'opt'
  print.c: In function 'ipset_print_proto':

A possible fix is just to remove -Wunused, as -Wextra + -Wunused enables
-Wunused-paramter.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: ipset/configure.ac
===================================================================
--- ipset.orig/configure.ac	2011-01-18 14:47:46.000000000 +0100
+++ ipset/configure.ac	2011-01-18 14:56:11.000000000 +0100
@@ -144,7 +144,6 @@
 AX_CFLAGS_GCC_OPTION(-Wstrict-prototypes)
 AX_CFLAGS_GCC_OPTION(-Wswitch-default)
 AX_CFLAGS_GCC_OPTION(-Wundef)
-AX_CFLAGS_GCC_OPTION(-Wunused)
 AX_CFLAGS_GCC_OPTION(-Wwrite-strings)
 
 dnl Checks for library functions.

-- 
