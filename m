From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 7/22]: Use rtattr_strcmp where appropriate
Date: Mon, 10 Jan 2005 20:37:54 +0100
Message-ID: <41E2D992.7000300@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010606020202010102000701"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010606020202010102000701
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------010606020202010102000701
Content-Type: text/x-patch;
 name="07.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="07.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/09 22:54:01+01:00 kaber@coreworks.de 
#   [RTNETLINK]: Use rtattr_strcmp where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2005/01/09 22:53:52+01:00 kaber@coreworks.de +1 -1
#   [RTNETLINK]: Use rtattr_strcmp where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/fib_rules.c
#   2005/01/09 22:53:52+01:00 kaber@coreworks.de +1 -1
#   [RTNETLINK]: Use rtattr_strcmp where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/devinet.c
#   2005/01/09 22:53:52+01:00 kaber@coreworks.de +1 -1
#   [RTNETLINK]: Use rtattr_strcmp where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/decnet/dn_rules.c
#   2005/01/09 22:53:52+01:00 kaber@coreworks.de +1 -1
#   [RTNETLINK]: Use rtattr_strcmp where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/decnet/dn_dev.c
#   2005/01/09 22:53:52+01:00 kaber@coreworks.de +1 -1
#   [RTNETLINK]: Use rtattr_strcmp where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
--- a/net/decnet/dn_dev.c	2005-01-10 06:22:11 +01:00
+++ b/net/decnet/dn_dev.c	2005-01-10 06:22:11 +01:00
@@ -662,7 +662,7 @@
 	for(ifap = &dn_db->ifa_list; (ifa=*ifap) != NULL; ifap = &ifa->ifa_next) {
 		void *tmp = rta[IFA_LOCAL-1];
 		if ((tmp && memcmp(RTA_DATA(tmp), &ifa->ifa_local, 2)) ||
-				(rta[IFA_LABEL-1] && strcmp(RTA_DATA(rta[IFA_LABEL-1]), ifa->ifa_label)))
+		    (rta[IFA_LABEL-1] && rtattr_strcmp(rta[IFA_LABEL-1], ifa->ifa_label)))
 			continue;
 
 		dn_dev_del_ifa(dn_db, ifap, 1);
diff -Nru a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
--- a/net/decnet/dn_rules.c	2005-01-10 06:22:11 +01:00
+++ b/net/decnet/dn_rules.c	2005-01-10 06:22:11 +01:00
@@ -88,7 +88,7 @@
 #endif
 			(!rtm->rtm_type || rtm->rtm_type == r->r_action) &&
 			(!rta[RTA_PRIORITY-1] || memcmp(RTA_DATA(rta[RTA_PRIORITY-1]), &r->r_preference, 4) == 0) &&
-			(!rta[RTA_IIF-1] || strcmp(RTA_DATA(rta[RTA_IIF-1]), r->r_ifname) == 0) &&
+			(!rta[RTA_IIF-1] || rtattr_strcmp(rta[RTA_IIF-1], r->r_ifname) == 0) &&
 			(!rtm->rtm_table || (r && rtm->rtm_table == r->r_table))) {
 
 			err = -EPERM;
diff -Nru a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c	2005-01-10 06:22:11 +01:00
+++ b/net/ipv4/devinet.c	2005-01-10 06:22:11 +01:00
@@ -399,7 +399,7 @@
 		     memcmp(RTA_DATA(rta[IFA_LOCAL - 1]),
 			    &ifa->ifa_local, 4)) ||
 		    (rta[IFA_LABEL - 1] &&
-		     strcmp(RTA_DATA(rta[IFA_LABEL - 1]), ifa->ifa_label)) ||
+		     rtattr_strcmp(rta[IFA_LABEL - 1], ifa->ifa_label)) ||
 		    (rta[IFA_ADDRESS - 1] &&
 		     (ifm->ifa_prefixlen != ifa->ifa_prefixlen ||
 		      !inet_ifa_match(*(u32*)RTA_DATA(rta[IFA_ADDRESS - 1]),
diff -Nru a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
--- a/net/ipv4/fib_rules.c	2005-01-10 06:22:11 +01:00
+++ b/net/ipv4/fib_rules.c	2005-01-10 06:22:11 +01:00
@@ -119,7 +119,7 @@
 #endif
 		    (!rtm->rtm_type || rtm->rtm_type == r->r_action) &&
 		    (!rta[RTA_PRIORITY-1] || memcmp(RTA_DATA(rta[RTA_PRIORITY-1]), &r->r_preference, 4) == 0) &&
-		    (!rta[RTA_IIF-1] || strcmp(RTA_DATA(rta[RTA_IIF-1]), r->r_ifname) == 0) &&
+		    (!rta[RTA_IIF-1] || rtattr_strcmp(rta[RTA_IIF-1], r->r_ifname) == 0) &&
 		    (!rtm->rtm_table || (r && rtm->rtm_table == r->r_table))) {
 			err = -EPERM;
 			if (r == &local_rule)
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2005-01-10 06:22:11 +01:00
+++ b/net/sched/act_api.c	2005-01-10 06:22:11 +01:00
@@ -112,7 +112,7 @@
 	if (kind) {
 		read_lock(&act_mod_lock);
 		for (a = act_base; a; a = a->next) {
-			if (strcmp((char*)RTA_DATA(kind), a->kind) == 0) {
+			if (rtattr_strcmp(kind, a->kind) == 0) {
 				if (!try_module_get(a->owner)) {
 					read_unlock(&act_mod_lock);
 					return NULL;

--------------010606020202010102000701--
