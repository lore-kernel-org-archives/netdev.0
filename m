From: Dave Jones <davej@redhat.com>
Subject: linked list corruption/use after free on bonding unload.
Date: Tue, 9 Apr 2013 14:50:02 -0400
Message-ID: <20130409185002.GA3784@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21710 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759304Ab3DITX4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 15:23:56 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r39JNuKO024491
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 9 Apr 2013 15:23:56 -0400
Received: from gelk.kernelslacker.org (ovpn-113-66.phx2.redhat.com [10.3.113.66])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r39Io359015225
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 9 Apr 2013 14:50:04 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.6/8.14.5) with ESMTP id r39Io2HV005479
	for <netdev@vger.kernel.org>; Tue, 9 Apr 2013 14:50:02 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.6/8.14.6/Submit) id r39Io2NT005476
	for netdev@vger.kernel.org; Tue, 9 Apr 2013 14:50:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just hit this while doing a load/unload test of various modules.
No bonding configuration had been set up, just the module loaded.

bonding: bond0: released all slaves
------------[ cut here ]------------
WARNING: at lib/list_debug.c:93 __list_del_entry+0xa1/0xd0()
Hardware name: GA-MA78GM-S2H
list_del corruption. prev->next should be ffff88005b420be8, but was 6b6b6b6b6b6b6b6b
Pid: 3886605, comm: modprobe Not tainted 3.9.0-rc6+ #19
Call Trace:
 [<ffffffff810450a5>] warn_slowpath_common+0x75/0xa0
 [<ffffffff8104511c>] warn_slowpath_fmt+0x4c/0x50
 [<ffffffff816b8502>] ? printk+0x67/0x69
 [<ffffffff81353df1>] __list_del_entry+0xa1/0xd0
 [<ffffffff81353e2d>] list_del+0xd/0x30
 [<ffffffffa14c444b>] bond_uninit+0x6b/0xd0 [bonding]
 [<ffffffff81581560>] rollback_registered_many+0x150/0x210
 [<ffffffff81581749>] unregister_netdevice_many+0x19/0x60
 [<ffffffff8159427e>] __rtnl_link_unregister+0x6e/0xb0
 [<ffffffff815942e3>] rtnl_link_unregister+0x23/0x30
 [<ffffffffa14ce96b>] bonding_exit+0x2d/0x6c2 [bonding]
 [<ffffffff810c5bc5>] sys_delete_module+0x165/0x2f0
 [<ffffffff810b6ac5>] ? trace_hardirqs_on_caller+0x115/0x1a0
 [<ffffffff8134b18e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff816cdcc2>] system_call_fastpath+0x16/0x1b
---[ end trace ffa4539b4be32cfa ]---
