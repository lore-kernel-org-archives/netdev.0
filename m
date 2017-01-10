From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] rttable: Fix invalid range checking when table id is converted to u32
Date: Tue, 10 Jan 2017 15:33:55 -0800
Message-ID: <1484091235-17749-1-git-send-email-dsa@cumulusnetworks.com>
Cc: frank.kellermann@atos.net, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36635 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdAJXeB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 18:34:01 -0500
Received: by mail-pf0-f171.google.com with SMTP id 189so42136950pfu.3
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 15:34:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank reported that table ids for very large numbers are not properly
detected:
$ ip li add foobar type vrf table 98765432100123456789

command succeeds and resulting table id is actually:

21: foobar: <NOARP,MASTER> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether da:ea:d4:77:38:2a brd ff:ff:ff:ff:ff:ff promiscuity 0
    vrf table 4294967295 addrgenmode eui64 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535

Make the temp variable 'i' unsigned long and let the typecast to u32
happen on assignment to id.

Reported-by: Frank Kellermann <frank.kellermann@atos.net>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 lib/rt_names.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/rt_names.c b/lib/rt_names.c
index c66cb1e439e3..63687586508b 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -404,7 +404,7 @@ int rtnl_rttable_a2n(__u32 *id, const char *arg)
 	static unsigned long res;
 	struct rtnl_hash_entry *entry;
 	char *end;
-	__u32 i;
+	unsigned long i;
 
 	if (cache && strcmp(cache, arg) == 0) {
 		*id = res;
-- 
2.1.4
