From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: annoying u32 double listing
Date: Sun, 06 Feb 2005 22:55:42 +0100
Message-ID: <4206925E.8030107@trash.net>
References: <1107719343.1055.22.camel@jzny.localdomain> <42068EA2.6030507@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <42068EA2.6030507@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:

> The patch is wrong. The "divisor"-lines are missing in the output with
> your patch and it only hides the real error. ->walk is supposed to walk
> all filters of the given priority/protocol, but u32 walks all filters.
> This patch fixes it. Output with new patch:

The patch also applies to 2.4.

Regards
Patrick

>
>------------------------------------------------------------------------
>
>===== net/sched/cls_u32.c 1.25 vs edited =====
>--- 1.25/net/sched/cls_u32.c	2005-01-11 20:25:16 +01:00
>+++ edited/net/sched/cls_u32.c	2005-02-06 22:20:33 +01:00
>@@ -91,6 +91,7 @@
> {
> 	struct tc_u_hnode	*next;
> 	u32			handle;
>+	u32			prio;
> 	struct tc_u_common	*tp_c;
> 	int			refcnt;
> 	unsigned		divisor;
>@@ -323,6 +324,7 @@
> 	root_ht->divisor = 0;
> 	root_ht->refcnt++;
> 	root_ht->handle = tp_c ? gen_new_htid(tp_c) : 0x80000000;
>+	root_ht->prio = tp->prio;
> 
> 	if (tp_c == NULL) {
> 		tp_c = kmalloc(sizeof(*tp_c), GFP_KERNEL);
>@@ -703,6 +705,8 @@
> 		return;
> 
> 	for (ht = tp_c->hlist; ht; ht = ht->next) {
>+		if (ht->prio != tp->prio)
>+			continue;
> 		if (arg->count >= arg->skip) {
> 			if (arg->fn(tp, (unsigned long)ht, arg) < 0) {
> 				arg->stop = 1;
>  
>
