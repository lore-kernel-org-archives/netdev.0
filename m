From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel BUG at net/core/skbuff.c:1065!
Date: Sun, 16 Jun 2013 10:08:35 -0700
Message-ID: <1371402515.3252.169.camel@edumazet-glaptop>
References: <CA+ydwtoh-KDWn4S6RY-=AWX8xmM6+o2fTz6738_w6L6aYVKrMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, trinity@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Tommi Rantala <tt.rantala@gmail.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <trinity-owner@vger.kernel.org>
In-Reply-To: <CA+ydwtoh-KDWn4S6RY-=AWX8xmM6+o2fTz6738_w6L6aYVKrMQ@mail.gmail.com>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-06-16 at 13:47 +0300, Tommi Rantala wrote:
> Hello,
> 
> Hit this bug while fuzzing in a qemu virtual machine as the root user.
> 
> Kernel is v3.10-rc5-0-g317ddd2.
> 
> Tommi
> 
> [575180.874750] type=1401 audit(1371378748.322:7750): SELinux:
> unrecognized netlink message type=0 for sclass=36
> [575180.874750]
> [575191.358143] ------------[ cut here ]------------
> [575191.358498] kernel BUG at /build/linux/net/core/skbuff.c:1065!
> [575191.358498] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
> [575191.358498] CPU: 0 PID: 28554 Comm: trinity-child33 Not tainted
> 3.10.0-rc5 #1
> [575191.358498] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [575191.358498] task: ffff880005f0c7c0 ti: ffff88002cec6000 task.ti:
> ffff88002cec6000
> [575191.358498] RIP: 0010:[<ffffffff81eb602b>]  [<ffffffff81eb602b>]
> pskb_expand_head+0x3b/0x290
> [575191.358498] RSP: 0018:ffff88002cec79f0  EFLAGS: 00010202
> [575191.358498] RAX: 0000000000000002 RBX: ffff880010e7cd80 RCX:
> 0000000000000020
> [575191.358498] RDX: 000000000000003c RSI: 0000000000000000 RDI:
> ffff880010e7cd80
> [575191.358498] RBP: ffff88002cec7a28 R08: 0000000000000001 R09:
> 0000000000000000
> [575191.358498] R10: 0000000000000000 R11: 0000000000000000 R12:
> 000000000000002b
> [575191.358498] R13: 0000000000000000 R14: 0000000000000011 R15:
> 0000000040014b89
> [575191.358498] FS:  00007f3b21cd6700(0000) GS:ffff8800bf600000(0000)
> knlGS:0000000000000000
> [575191.358498] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [575191.358498] CR2: 00000000009fb000 CR3: 000000001a873000 CR4:
> 00000000000006f0
> [575191.358498] DR0: 0000000002592d30 DR1: 0000000000000000 DR2:
> 0000000000000000
> [575191.358498] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000600
> [575191.358498] Stack:
> [575191.358498]  ffff880090cbd668 0000000000000000 ffff880010e7cd80
> 000000000000002b
> [575191.358498]  0000000000000000 0000000000000011 0000000040014b89
> ffff88002cec7a50
> [575191.358498]  ffffffff81eb6fc3 ffff88002cec7a70 0000000000000011
> ffff8800b952d498
> [575191.358498] Call Trace:
> [575191.358498]  [<ffffffff81eb6fc3>] skb_pad+0xa3/0x150
> [575191.358498]  [<ffffffff81884c48>] e1000_xmit_frame+0x78/0xfc0
> [575191.358498]  [<ffffffff81ec1830>] ? dev_queue_xmit_nit+0x360/0x390
> [575191.358498]  [<ffffffff81ec14d0>] ? get_rps_cpu+0x4a0/0x4a0
> [575191.358498]  [<ffffffff81ec581c>] dev_hard_start_xmit+0x2ec/0x720
> [575191.358498]  [<ffffffff81ef4d10>] sch_direct_xmit+0x80/0x290
> [575191.358498]  [<ffffffff81ec6104>] dev_queue_xmit+0x4b4/0x8e0
> [575191.358498]  [<ffffffff81ec5c50>] ? dev_hard_start_xmit+0x720/0x720
> [575191.358498]  [<ffffffff81eefc3f>] llc_sap_action_send_test_c+0x7f/0x90
> [575191.358498]  [<ffffffff81eef270>] llc_sap_state_process+0xd0/0x160
> [575191.358498]  [<ffffffff81eef424>] llc_build_and_send_test_pkt+0x44/0x50
> [575191.358498]  [<ffffffff81ef1b47>] llc_ui_sendmsg+0x1e7/0x490
> [575191.358498]  [<ffffffff81eac5d1>] sock_sendmsg+0xa1/0xd0
> [575191.358498]  [<ffffffff8109a838>] ? __do_page_fault+0x288/0x530
> [575191.358498]  [<ffffffff81eacaac>] SYSC_sendto+0x11c/0x160
> [575191.358498]  [<ffffffff822a2247>] ? _raw_spin_unlock_irq+0x27/0x50
> [575191.358498]  [<ffffffff8111870c>] ? do_setitimer+0x27c/0x330
> [575191.358498]  [<ffffffff81172e46>] ? trace_hardirqs_on_caller+0x16/0x220
> [575191.358498]  [<ffffffff814d791e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [575191.358498]  [<ffffffff81eada69>] SyS_sendto+0x9/0x10
> [575191.358498]  [<ffffffff822a38e9>] system_call_fastpath+0x16/0x1b
> [575191.358498] Code: 48 89 fb 48 83 ec 10 8b 87 d4 00 00 00 01 f0 01
> c2 85 f6 79 0b 0f 0b 66 0f 1f 84 00 00 00 00 00 8b 87 ec 00 00 00 83
> f8 01 74 05 <0f> 0b 0f 1f 00 83 c2 3f 41 89 cf 83 e2 c0 f6 87 aa 00 00
> 00 04
> [575191.358498] RIP  [<ffffffff81eb602b>] pskb_expand_head+0x3b/0x290
> [575191.358498]  RSP <ffff88002cec79f0>
> [575191.518696] ---[ end trace 866084dcc0c2aa3e ]---
> [575191.522588] Kernel panic - not syncing: Fatal exception in interrupt
> [575191.523574] drm_kms_helper: panic occurred, switching back to text console
> --

llc_sap_state_process() is buggy, as it assumes skb->cb[] will be not
modified by lower layers.

Doing skb_get()/kfree_skb() is not enough to preserve skb->cb[].

skb_clone() is needed.

llc code seems to play games with skb->sk, so I am not sure following
patch is ok.

diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index 78be45c..621411e 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -201,15 +201,16 @@ out:
 static void llc_sap_state_process(struct llc_sap *sap, struct sk_buff *skb)
 {
 	struct llc_sap_state_ev *ev = llc_sap_ev(skb);
+	struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
+
+	if (!nskb) {
+		kfree_skb(skb);
+		return;
+	}
+	nskb->sk = skb->sk;
 
-	/*
-	 * We have to hold the skb, because llc_sap_next_state
-	 * will kfree it in the sending path and we need to
-	 * look at the skb->cb, where we encode llc_sap_state_ev.
-	 */
-	skb_get(skb);
 	ev->ind_cfm_flag = 0;
-	llc_sap_next_state(sap, skb);
+	llc_sap_next_state(sap, nskb);
 	if (ev->ind_cfm_flag == LLC_IND) {
 		if (skb->sk->sk_state == TCP_LISTEN)
 			kfree_skb(skb);
@@ -221,7 +222,6 @@ static void llc_sap_state_process(struct llc_sap *sap, struct sk_buff *skb)
 				kfree_skb(skb);
 		}
 	}
-	kfree_skb(skb);
 }
 
 /**
