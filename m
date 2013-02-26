From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [iproute2 ] Fix compilation error of m_ipt.c with -Werror enabled
Date: Tue, 26 Feb 2013 11:12:07 -0800
Message-ID: <1361905927-31534-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:39572 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757196Ab3BZTNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 14:13:16 -0500
Received: by mail-pa0-f54.google.com with SMTP id fa10so2615109pad.41
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 11:13:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit (5a650703d47e10aa386406c855eff5a593b2120b Makefile: make warnings into
errors ) causes the following build error.

gcc -Wall -Wstrict-prototypes -Werror -Wmissing-prototypes
-Wmissing-declarations -Wold-style-definition -O2 -I../include
-DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\"
-D_GNU_SOURCE -DCONFIG_GACT -DCONFIG_GACT_PROB -DIPT_LIB_DIR=\"/lib/xtables\"
-DYY_NO_INPUT   -c -o m_ipt.o m_ipt.c
cc1: warnings being treated as errors
m_ipt.c:72: error: no previous prototype for 'xtables_register_target'
m_ipt.c:361: error: no previous prototype for 'build_st'
make[1]: *** [m_ipt.o] Error 1

This is fixed by adding the prototype in the header include/iptables.h

I am not sure if this is due to something wrong on my build system but I am
using current glibc 2.17.


Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 include/iptables.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/iptables.h b/include/iptables.h
index dd844c1..f1e62e2 100644
--- a/include/iptables.h
+++ b/include/iptables.h
@@ -143,6 +143,8 @@ extern int line;
 /* Your shared library should call one of these. */
 extern void register_match(struct iptables_match *me);
 extern void register_target(struct iptables_target *me);
+extern void xtables_register_target(struct iptables_target *me);
+extern int build_st(struct iptables_target *target, struct ipt_entry_target *t);
 
 extern struct in_addr *dotted_to_addr(const char *dotted);
 extern char *addr_to_dotted(const struct in_addr *addrp);
-- 
1.7.0.4
