From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 2/3] Revert "ip netns: Fix rtnl error while print netns list"
Date: Mon, 13 Apr 2015 10:23:04 +0200
Message-ID: <1428913385-4331-2-git-send-email-nicolas.dichtel@6wind.com>
References: <5527F790.4080301@6wind.com>
 <1428913385-4331-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, vadim4j@gmail.com, jbenc@redhat.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40919 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbbDMIXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 04:23:13 -0400
In-Reply-To: <1428913385-4331-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit d116ff34145b00db54a37e2a6282dccd8bc08225.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 configure    | 21 +--------------------
 ip/Makefile  |  4 ----
 ip/ipnetns.c |  7 -------
 3 files changed, 1 insertion(+), 31 deletions(-)

diff --git a/configure b/configure
index 631938e97206..c3dacdba14ff 100755
--- a/configure
+++ b/configure
@@ -201,7 +201,7 @@ check_setns()
 {
     cat >$TMPDIR/setnstest.c <<EOF
 #include <sched.h>
-int main(int argc, char **argv)
+int main(int argc, char **argv) 
 {
 	(void)setns(0,0);
 	return 0;
@@ -218,23 +218,6 @@ EOF
     rm -f $TMPDIR/setnstest.c $TMPDIR/setnstest
 }
 
-check_netnsid()
-{
-    cat >$TMPDIR/netnsid.c <<EOF
-#include <linux/rtnetlink.h>
-int test_def = RTM_GETNSID;
-EOF
-    $CC -c $TMPDIR/netnsid.c >/dev/null 2>&1
-    if [ $? -eq 0 ]
-    then
-	echo "IP_CONFIG_NETNSID:=y" >> Config
-	echo "yes"
-    else
-	echo "no"
-    fi
-    rm -f $TMPDIR/netnsid.c $TMPDIR/netnsid.o
-}
-
 check_ipset()
 {
     cat >$TMPDIR/ipsettest.c <<EOF
@@ -300,8 +283,6 @@ check_ipt_lib_dir
 
 echo -n "libc has setns: "
 check_setns
-echo -n "netns has peer id suport: "
-check_netnsid
 
 echo -n "SELinux support: "
 check_selinux
diff --git a/ip/Makefile b/ip/Makefile
index 5637bcfebde0..2c742f305fef 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -16,10 +16,6 @@ ifeq ($(IP_CONFIG_SETNS),y)
 	CFLAGS += -DHAVE_SETNS
 endif
 
-ifeq ($(IP_CONFIG_NETNSID),y)
-	CFLAGS += -DHAVE_NETNSID
-endif
-
 ALLOBJ=$(IPOBJ) $(RTMONOBJ)
 SCRIPTS=ifcfg rtpr routel routef
 TARGETS=ip rtmon
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 45e234a4d98c..5a213dcf46cd 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -34,7 +34,6 @@ static int usage(void)
 	exit(-1);
 }
 
-#ifdef HAVE_NETNSID
 static int get_netnsid_from_name(const char *name)
 {
 	struct {
@@ -79,12 +78,6 @@ static int get_netnsid_from_name(const char *name)
 
 	return -1;
 }
-#else
-static int get_netnsid_from_name(const char *name)
-{
-	return -1;
-}
-#endif /* HAVE_NETNSID */
 
 static int netns_list(int argc, char **argv)
 {
-- 
2.2.2
