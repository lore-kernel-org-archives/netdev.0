From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6]: Fix oops in ipt action error path
Date: Thu, 09 Dec 2004 00:07:26 +0100
Message-ID: <41B7892E.1080706@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080100080308010505080402"
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080100080308010505080402
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes an oops when the ipt action is used with a
non-existant iptables target. It tries to log
t->u.kernel.target->name, u.kernel.target is part of a union
and as long as the target wasn't successfully loaded contains
the name of the target, using it as a pointer results in a
crash.

Oops captured in UML:

EIP: 0023:[<a01056e1>] CPU: 0 Not tainted ESP: 002b:a14b7514 EFLAGS: 
00010297
    Not tainted
EAX: 414d4e56 EBX: 0000000a ECX: 414d4e56 EDX: fffffffe
ESI: a036acba EDI: 00000000 EBP: a036b09f DS: 002b ES: 002b
Call Trace:
 [<a004b96d>] notifier_call_chain+0x2d/0x50
 [<a0101186>] bust_spinlocks+0x46/0x50
 [<a0035cc1>] panic+0x71/0x120
 [<a01056e1>] vsnprintf+0x331/0x4d0
 [<a001ad6a>] segv+0x1fa/0x230
 [<a01056e1>] vsnprintf+0x331/0x4d0
 [<a01eaeb4>] sigemptyset+0x24/0x40
 [<a0018c65>] change_signals+0x65/0x90
 [<a001b1c0>] segv_handler+0xe0/0xf0
 [<a01056e1>] vsnprintf+0x331/0x4d0
 [<a001eccd>] sig_handler_common_tt+0x8d/0x120
 [<a001b1f7>] sig_handler+0x17/0x20
 [<a01ead88>] __restore+0x0/0x8
 [<a01056e1>] vsnprintf+0x331/0x4d0
 [<a01058ab>] vscnprintf+0x2b/0x40
 [<a0036df2>] vprintk+0xb2/0x320
 [<a0036d37>] printk+0x17/0x20
 [<a0163653>] tcf_ipt_init+0x533/0x750
 [<a015ea22>] tcf_action_init_1+0x92/0x1a0
 [<a0069219>] kmem_cache_alloc+0x39/0x60
 [<a01eaeb4>] sigemptyset+0x24/0x40
 [<a015ebd7>] tcf_action_init+0xa7/0x140
...

Not very important right now since ipt support isn't merged in iproute
yet, but still should be fixed for 2.6.10.

Regards
Patrick


--------------080100080308010505080402
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/08 23:59:19+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Fix oops in ipt action error path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/ipt.c
#   2004/12/08 23:59:13+01:00 kaber@coreworks.de +1 -2
#   [PKT_SCHED]: Fix oops in ipt action error path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/ipt.c b/net/sched/ipt.c
--- a/net/sched/ipt.c	2004-12-08 23:59:51 +01:00
+++ b/net/sched/ipt.c	2004-12-08 23:59:51 +01:00
@@ -63,8 +63,7 @@
 	target = __ipt_find_target_lock(t->u.user.name, &ret);
 
 	if (!target) {
-		printk("init_targ: Failed to find %s\n",
-		       t->u.kernel.target->name);
+		printk("init_targ: Failed to find %s\n", t->u.user.name);
 		return -1;
 	}
 

--------------080100080308010505080402--
