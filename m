From: Matteo Croce <mcroce@redhat.com>
Subject: [PATCH] netns: more input validation
Date: Tue, 25 Jul 2017 15:30:31 +0200
Message-ID: <20170725133031.7735-1-mcroce@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37236 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750980AbdGYNaf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 09:30:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip netns accepts invalid input as namespace name like an empty string or a
string longer than the maximum file name length.
Check that the netns name is not empty and less than or equal to NAME_MAX.

Signed-off-by: Matteo Croce <mcroce@redhat.com>
---
 ip/ipnetns.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 42549944..198e9de8 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -768,7 +768,8 @@ static int netns_monitor(int argc, char **argv)
 
 static int invalid_name(const char *name)
 {
-	return strchr(name, '/') || !strcmp(name, ".") || !strcmp(name, "..");
+	return !*name || strlen(name) > NAME_MAX ||
+		strchr(name, '/') || !strcmp(name, ".") || !strcmp(name, "..");
 }
 
 int do_netns(int argc, char **argv)
-- 
2.11.0
