From: Dave Jones <davej@redhat.com>
Subject: llc: remove noisy WARN from llc_mac_hdr_init
Date: Tue, 28 Jan 2014 16:30:52 -0500
Message-ID: <20140128213052.GA10689@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755719AbaA1VbA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jan 2014 16:31:00 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0SLV0SO014311
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 28 Jan 2014 16:31:00 -0500
Received: from gelk.kernelslacker.org (ovpn-113-178.phx2.redhat.com [10.3.113.178])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s0SLUsOC009919
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 28 Jan 2014 16:30:59 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.7/8.14.7) with ESMTP id s0SLUrMA010872
	for <netdev@vger.kernel.org>; Tue, 28 Jan 2014 16:30:53 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.7/8.14.7/Submit) id s0SLUrm0010871
	for netdev@vger.kernel.org; Tue, 28 Jan 2014 16:30:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sending malformed llc packets triggers this spew, which seems excessive.

WARNING: CPU: 1 PID: 6917 at net/llc/llc_output.c:46 llc_mac_hdr_init+0x85/0x90 [llc]()
device type not supported: 0
CPU: 1 PID: 6917 Comm: trinity-c1 Not tainted 3.13.0+ #95 
 0000000000000009 00000000007e257d ffff88009232fbe8 ffffffffac737325
 ffff88009232fc30 ffff88009232fc20 ffffffffac06d28d ffff88020e07f180
 ffff88009232fec0 00000000000000c8 0000000000000000 ffff88009232fe70
Call Trace:
 [<ffffffffac737325>] dump_stack+0x4e/0x7a
 [<ffffffffac06d28d>] warn_slowpath_common+0x7d/0xa0
 [<ffffffffac06d30c>] warn_slowpath_fmt+0x5c/0x80
 [<ffffffffc01736d5>] llc_mac_hdr_init+0x85/0x90 [llc]
 [<ffffffffc0173759>] llc_build_and_send_ui_pkt+0x79/0x90 [llc]
 [<ffffffffc057cdba>] llc_ui_sendmsg+0x23a/0x400 [llc2]
 [<ffffffffac605d8c>] sock_sendmsg+0x9c/0xe0
 [<ffffffffac185a37>] ? might_fault+0x47/0x50
 [<ffffffffac606321>] SYSC_sendto+0x121/0x1c0
 [<ffffffffac011847>] ? syscall_trace_enter+0x207/0x270
 [<ffffffffac6071ce>] SyS_sendto+0xe/0x10
 [<ffffffffac74aaa4>] tracesys+0xdd/0xe2

Until 2009, this was a printk, when it was changed in
bf9ae5386bc: "llc: use dev_hard_header".

Let userland figure out what -EINVAL means by itself.

Signed-off-by: Dave Jones <davej@fedoraproject.org>

diff --git a/net/llc/llc_output.c b/net/llc/llc_output.c
index 2dae8a5df23f..94425e421213 100644
--- a/net/llc/llc_output.c
+++ b/net/llc/llc_output.c
@@ -43,7 +43,7 @@ int llc_mac_hdr_init(struct sk_buff *skb,
 			rc = 0;
 		break;
 	default:
-		WARN(1, "device type not supported: %d\n", skb->dev->type);
+		break;
 	}
 	return rc;
 }
