From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6 5/5]: act_api: mark some functions static/remove	unused
 function
Date: Thu, 04 Nov 2004 16:28:32 +0100
Message-ID: <418A4AA0.8070609@trash.net>
References: <4189CB70.3060703@trash.net> <1099576602.1039.151.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070506020303020400050606"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1099576602.1039.151.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070506020303020400050606
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

jamal wrote:

>On Thu, 2004-11-04 at 01:25, Patrick McHardy wrote:
>  
>
>>tc_lookup_action_id was unused
>>so I removed it.
>>    
>>
>
>Please dont.
>
Ok, here is the same patch without removing tc_lookup_action_id.
It is instead surrounded by #if 0.

>I am incrementally submitting patches.
>
I was about to do more cleanup, please stop me if you are already doing
any of this:

- move the functions from include/net/pkt_act.h to act_generic.c
- convert lastuse/install/expires to USER_HZ
- fix ipt: leaks memory at destruction, ovr doesn't work, doesn't refcount
  iptables module references

Is there already userspace-code for anything besides gact ?
I would like to test my changes.

Regards
Patrick



--------------070506020303020400050606
Content-Type: text/x-patch;
 name="5.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="5.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/04 16:11:08+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: act_api: mark some functions static
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2004/11/04 16:11:02+01:00 kaber@coreworks.de +13 -11
#   [PKT_SCHED]: act_api: mark some functions static
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2004-11-04 16:11:32 +01:00
+++ b/net/sched/act_api.c	2004-11-04 16:11:32 +01:00
@@ -88,7 +88,7 @@
 }
 
 /* lookup by name */
-struct tc_action_ops *tc_lookup_action_n(char *kind)
+static struct tc_action_ops *tc_lookup_action_n(char *kind)
 {
 
 	struct tc_action_ops *a = NULL;
@@ -111,7 +111,7 @@
 }
 
 /* lookup by rtattr */
-struct tc_action_ops *tc_lookup_action(struct rtattr *kind)
+static struct tc_action_ops *tc_lookup_action(struct rtattr *kind)
 {
 
 	struct tc_action_ops *a = NULL;
@@ -134,6 +134,7 @@
 	return a;
 }
 
+#if 0
 /* lookup by id */
 struct tc_action_ops *tc_lookup_action_id(u32 type)
 {
@@ -155,6 +156,7 @@
 
 	return a;
 }
+#endif
 
 int tcf_action_exec(struct sk_buff *skb,struct tc_action *act, struct tcf_result *res)
 {
@@ -504,7 +506,7 @@
 	return err;
 }
 
-int tcf_action_get_1(struct rtattr *rta, struct tc_action *a, struct nlmsghdr *n, u32 pid)
+static int tcf_action_get_1(struct rtattr *rta, struct tc_action *a, struct nlmsghdr *n, u32 pid)
 {
 	struct tc_action_ops *a_o;
 	char act_name[4 + IFNAMSIZ + 1];
@@ -571,7 +573,7 @@
 	return err;
 }
 
-void cleanup_a (struct tc_action *act) 
+static void cleanup_a (struct tc_action *act) 
 {
 	struct tc_action *a;
 
@@ -587,7 +589,7 @@
 	}
 }
 
-struct tc_action_ops *get_ao(struct rtattr *kind, struct tc_action *a)
+static struct tc_action_ops *get_ao(struct rtattr *kind, struct tc_action *a)
 {
 	char act_name[4 + IFNAMSIZ + 1];
 	struct tc_action_ops *a_o = NULL;
@@ -622,7 +624,7 @@
 	return a_o;
 }
 
-struct tc_action *create_a(int i)
+static struct tc_action *create_a(int i)
 {
 	struct tc_action *act = NULL;
 
@@ -639,7 +641,7 @@
 	return act;
 }
 
-int tca_action_flush(struct rtattr *rta, struct nlmsghdr *n, u32 pid)
+static int tca_action_flush(struct rtattr *rta, struct nlmsghdr *n, u32 pid)
 {
 	struct sk_buff *skb;
 	unsigned char *b;
@@ -709,7 +711,7 @@
 	return err;
 }
 
-int tca_action_gd(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int event )
+static int tca_action_gd(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int event )
 {
 
 	int s = 0;
@@ -793,7 +795,7 @@
 }
 
 
-int tcf_add_notify(struct tc_action *a, u32 pid, u32 seq, int event, unsigned flags) 
+static int tcf_add_notify(struct tc_action *a, u32 pid, u32 seq, int event, unsigned flags) 
 {
 	struct tcamsg *t;
 	struct nlmsghdr  *nlh;
@@ -840,7 +842,7 @@
 }
 
 	
-int tcf_action_add(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int ovr ) 
+static int tcf_action_add(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int ovr ) 
 {
 	int ret = 0;
 	struct tc_action *act = NULL;
@@ -923,7 +925,7 @@
 	return ret;
 }
 
-char *
+static char *
 find_dump_kind(struct nlmsghdr *n)
 {
 	struct rtattr *tb1, *tb2[TCA_ACT_MAX+1];

--------------070506020303020400050606--
