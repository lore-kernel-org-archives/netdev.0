From: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] openvswitch: using nla_for_each_X to simplify the
	code
Date: Sun, 7 Oct 2012 21:42:42 +0800
Message-ID: <CAPgLHd8hY-nZWaG-meEk1MtY5Rj_26Lj1bxH=jtn20jxni+U8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org
To: jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>

Using nla_for_each_nested() or nla_for_each_attr()
to simplify the code.

dpatch engine is used to auto generate this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
---
 net/openvswitch/actions.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 0811447..b67594f 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -288,8 +288,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 	upcall.userdata = NULL;
 	upcall.portid = 0;
 
-	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
-		 a = nla_next(a, &rem)) {
+	nla_for_each_nested(a, attr, rem) {
 		switch (nla_type(a)) {
 		case OVS_USERSPACE_ATTR_USERDATA:
 			upcall.userdata = a;
@@ -311,8 +310,7 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 	const struct nlattr *a;
 	int rem;
 
-	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
-		 a = nla_next(a, &rem)) {
+	nla_for_each_nested(a, attr, rem) {
 		switch (nla_type(a)) {
 		case OVS_SAMPLE_ATTR_PROBABILITY:
 			if (net_random() >= nla_get_u32(a))
@@ -371,8 +369,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 	const struct nlattr *a;
 	int rem;
 
-	for (a = attr, rem = len; rem > 0;
-	     a = nla_next(a, &rem)) {
+	nla_for_each_attr(a, attr, len, rem) {
 		int err = 0;
 
 		if (prev_port != -1) {
