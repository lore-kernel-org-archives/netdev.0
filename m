From: Nigel Kukard <nkukard@lbsd.net>
Subject: [RESEND] [PATCH] Fix tc stats when using -batch mode
Date: Wed, 30 Oct 2013 18:44:58 +0000
Message-ID: <sig.10159dd6fd.20131030184444.GA34797@lbsd.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from uk.eu.mailhost.iitsp.com ([217.147.85.13]:46560 "EHLO
	uk.eu.mailhost.iitsp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055Ab3J3Sxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 14:53:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two global variables in tc/tc_class.c:
__u32 filter_qdisc;
__u32 filter_classid;

These are not re-initialized for each line received in -batch mode:
class show dev eth0 parent 1: classid 1:1
class show dev eth0 parent 1: classid 1:1
Error: duplicate "classid": "1:1" is the second value.

This patch fixes the issue by initializing the two globals when we
enter print_class().

Signed-off-by: Nigel Kukard <nkukard@lbsd.net>
---
 tc/tc_class.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/tc/tc_class.c b/tc/tc_class.c
index 9d4eea5..8043448 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -241,6 +241,9 @@ int tc_class_list(int argc, char **argv)
 	t.tcm_family = AF_UNSPEC;
 	memset(d, 0, sizeof(d));
 
+	filter_qdisc = 0;
+	filter_classid = 0;
+
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
-- 
1.8.4.rc3
