From: Dave Jones <davej@redhat.com>
Subject: kmalloc with locks held in xfrm.
Date: Thu, 27 Feb 2014 10:19:54 -0500
Message-ID: <20140227151954.GA30946@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2291 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752641AbaB0PjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 10:39:23 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s1RFdMBL025363
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 10:39:22 -0500
Received: from gelk.kernelslacker.org (ovpn-113-186.phx2.redhat.com [10.3.113.186])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s1RFJtiX001919
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 10:20:01 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.8/8.14.7) with ESMTP id s1RFJtb2031109
	for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 10:19:55 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.8/8.14.8/Submit) id s1RFJsiw031108
	for netdev@vger.kernel.org; Thu, 27 Feb 2014 10:19:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hit this trace this morning on rc4.

	Dave

BUG: sleeping function called from invalid context at mm/slub.c:965
in_atomic(): 0, irqs_disabled(): 0, pid: 28692, name: trinity-main
2 locks held by trinity-main/28692:
 #0:  (sk_lock-AF_INET){......}, at: [<ffffffff83660cd3>] do_ip_setsockopt.isra.12+0x63/0xe10
 #1:  (rcu_read_lock){......}, at: [<ffffffff836bf138>] xfrm_user_policy+0xa8/0x1c0
CPU: 0 PID: 28692 Comm: trinity-main Not tainted 3.14.0-rc4+ #125 
 ffffffff83a428e7 00000000707766bf ffff88008c749c50 ffffffff8372e248
 ffff8800075c45c0 ffff88008c749c80 ffffffff8309c525 00000000000000d0
 00000000000000d0 0000000000000008 ffff880244c04240 ffff88008c749cd8
Call Trace:
 [<ffffffff8372e248>] dump_stack+0x4e/0x7a
 [<ffffffff8309c525>] __might_sleep+0x125/0x180
 [<ffffffff831acd6a>] __kmalloc+0x7a/0x2a0
 [<ffffffffc05978d8>] ? pfkey_compile_policy+0x1a8/0x270 [af_key]
 [<ffffffffc05978d8>] pfkey_compile_policy+0x1a8/0x270 [af_key]
 [<ffffffff836bf1b7>] xfrm_user_policy+0x127/0x1c0
 [<ffffffff836bf138>] ? xfrm_user_policy+0xa8/0x1c0
 [<ffffffff83071907>] ? __local_bh_enable_ip+0x67/0xe0
 [<ffffffff8366173e>] do_ip_setsockopt.isra.12+0xace/0xe10
 [<ffffffff831c1e7c>] ? get_empty_filp+0x5c/0x240
 [<ffffffff830bcab5>] ? cpuacct_account_field+0x5/0xc0
 [<ffffffff8310ff8e>] ? __acct_update_integrals+0x8e/0x120
 [<ffffffff830a388d>] ? get_parent_ip+0xd/0x50
 [<ffffffff8373d42b>] ? preempt_count_sub+0x6b/0xf0
 [<ffffffff83661ab0>] ip_setsockopt+0x30/0xa0
 [<ffffffff836872eb>] udp_setsockopt+0x1b/0x40
 [<ffffffff83600dc4>] sock_common_setsockopt+0x14/0x20
 [<ffffffff835ffa30>] SyS_setsockopt+0x80/0xf0
 [<ffffffff83741e6a>] tracesys+0xd4/0xd9
