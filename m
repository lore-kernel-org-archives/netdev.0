From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: annoying u32 double listing
Date: Mon, 07 Feb 2005 00:17:30 +0100
Message-ID: <4206A58A.9050909@trash.net>
References: <1107719343.1055.22.camel@jzny.localdomain>	 <42068EA2.6030507@trash.net> <1107727330.1053.44.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070706000209020107090804"
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1107727330.1053.44.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070706000209020107090804
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

jamal wrote:

>I should have caught that output missing divisor ;->
>Dave please apply Patricks version. Should probably apply cleanly on
>2.4.x as well.
>
My last patch has a similar problem, new hash tables added with
"u32 divisor .." are skipped while walking. This patch is better
tested and should be fine. Applies to 2.4 and 2.6.

Regards
Patrick


--------------070706000209020107090804
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/02/07 00:16:17+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Fix u32 double listing
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/cls_u32.c
#   2005/02/07 00:16:08+01:00 kaber@coreworks.de +5 -0
#   [PKT_SCHED]: Fix u32 double listing
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/cls_u32.c b/net/sched/cls_u32.c
--- a/net/sched/cls_u32.c	2005-02-07 00:16:37 +01:00
+++ b/net/sched/cls_u32.c	2005-02-07 00:16:37 +01:00
@@ -91,6 +91,7 @@
 {
 	struct tc_u_hnode	*next;
 	u32			handle;
+	u32			prio;
 	struct tc_u_common	*tp_c;
 	int			refcnt;
 	unsigned		divisor;
@@ -323,6 +324,7 @@
 	root_ht->divisor = 0;
 	root_ht->refcnt++;
 	root_ht->handle = tp_c ? gen_new_htid(tp_c) : 0x80000000;
+	root_ht->prio = tp->prio;
 
 	if (tp_c == NULL) {
 		tp_c = kmalloc(sizeof(*tp_c), GFP_KERNEL);
@@ -587,6 +589,7 @@
 		ht->refcnt = 0;
 		ht->divisor = divisor;
 		ht->handle = handle;
+		ht->prio = tp->prio;
 		ht->next = tp_c->hlist;
 		tp_c->hlist = ht;
 		*arg = (unsigned long)ht;
@@ -703,6 +706,8 @@
 		return;
 
 	for (ht = tp_c->hlist; ht; ht = ht->next) {
+		if (ht->prio != tp->prio)
+			continue;
 		if (arg->count >= arg->skip) {
 			if (arg->fn(tp, (unsigned long)ht, arg) < 0) {
 				arg->stop = 1;

--------------070706000209020107090804--
