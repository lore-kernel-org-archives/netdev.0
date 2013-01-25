From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 6/8] qlcnic: sleeping function called from invalid context
Date: Fri, 25 Jan 2013 15:20:39 -0500
Message-ID: <1359145241-5175-7-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1359145241-5175-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:26513 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751372Ab3AYUl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 15:41:27 -0500
In-Reply-To: <1359145241-5175-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

device eth0 entered promiscuous mode
BUG: sleeping function called from invalid context at mm/slub.c:930
in_atomic(): 1, irqs_disabled(): 0, pid: 5911, name: brctl
INFO: lockdep is turned off.
Pid: 5911, comm: brctl Tainted: GF       W  O 3.6.0-0.rc7.git1.4.fc18.x86_64 #1
Call Trace:
[<ffffffff810a29ca>] __might_sleep+0x18a/0x240
[<ffffffff811b5d77>] __kmalloc+0x67/0x2d0
[<ffffffffa00a61a9>] ? qlcnic_alloc_lb_filters_mem+0x59/0xa0 [qlcnic]
[<ffffffffa00a61a9>] qlcnic_alloc_lb_filters_mem+0x59/0xa0 [qlcnic]
[<ffffffffa009e1c1>] qlcnic_set_multi+0x81/0x100 [qlcnic]
[<ffffffff8159cccf>] __dev_set_rx_mode+0x5f/0xb0
[<ffffffff8159cd4f>] dev_set_rx_mode+0x2f/0x50
[<ffffffff8159d00c>] dev_set_promiscuity+0x3c/0x50
[<ffffffffa05ed728>] br_add_if+0x1e8/0x400 [bridge]
[<ffffffffa05ee2df>] add_del_if+0x5f/0x90 [bridge]
[<ffffffffa05eee0b>] br_dev_ioctl+0x4b/0x90 [bridge]
[<ffffffff8159d613>] dev_ifsioc+0x373/0x3b0
[<ffffffff8159d78f>] dev_ioctl+0x13f/0x860
[<ffffffff812dd6e1>] ? avc_has_perm_flags+0x31/0x2c0
[<ffffffff8157c18d>] sock_do_ioctl+0x5d/0x70
[<ffffffff8157c21d>] sock_ioctl+0x7d/0x2c0
[<ffffffff812df922>] ? inode_has_perm.isra.48.constprop.61+0x62/0xa0
[<ffffffff811e4979>] do_vfs_ioctl+0x99/0x5a0
[<ffffffff812df9f7>] ? file_has_perm+0x97/0xb0
[<ffffffff810d716d>] ? trace_hardirqs_on+0xd/0x10
[<ffffffff811e4f19>] sys_ioctl+0x99/0xa0
[<ffffffff816e7369>] system_call_fastpath+0x16/0x1b
br0: port 1(eth0) entered forwarding state
br0: port 1(eth0) entered forwarding state

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 5cbf8c6..8b0f47a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2142,7 +2142,7 @@ void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter)
 	}
 
 	head = kcalloc(adapter->fhash.fbucket_size,
-		       sizeof(struct hlist_head), GFP_KERNEL);
+		       sizeof(struct hlist_head), GFP_ATOMIC);
 
 	if (!head)
 		return;
-- 
1.7.1
