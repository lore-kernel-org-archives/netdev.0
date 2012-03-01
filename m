From: Dave Jones <davej@redhat.com>
Subject: sleeping function called from invalid context (rtnetlink)
Date: Thu, 1 Mar 2012 18:59:28 -0500
Message-ID: <20120301235928.GA28088@redhat.com>
References: <bug-799099-176318@bugzilla.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fedora Kernel Team <kernel-team@fedoraproject.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12551 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753199Ab2CAX7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 18:59:31 -0500
Content-Disposition: inline
In-Reply-To: <bug-799099-176318@bugzilla.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just had this reported by a Fedora user.
It's against 3.3-rc4, but afaik, the only changes to rtnetlink
since then wouldn't have fixed this unless I've overlooked something.

https://bugzilla.redhat.com/show_bug.cgi?id=799099

BUG: sleeping function called from invalid context at kernel/mutex.c:271
in_atomic(): 1, irqs_disabled(): 0, pid: 10451, name: NetworkManager
INFO: lockdep is turned off.
Pid: 10451, comm: NetworkManager Not tainted 3.3.0-0.rc4.git1.4.fc17.x86_64 #1
Call Trace:
 [<ffffffff810966fc>] __might_sleep+0x13c/0x200
 [<ffffffff8154c470>] ? sock_def_readable+0x30/0x1c0
 [<ffffffff8169a81e>] mutex_lock_nested+0x2e/0x3a0
 [<ffffffff81571100>] ? rtnetlink_net_init+0x50/0x50
 [<ffffffff8158e25c>] ? netlink_dump_start+0xdc/0x180
 [<ffffffff81571100>] ? rtnetlink_net_init+0x50/0x50
 [<ffffffff81571897>] rtnl_lock+0x17/0x20
 [<ffffffff81573ef8>] rtnetlink_rcv_msg+0x1f8/0x2e0
 [<ffffffff81571897>] ? rtnl_lock+0x17/0x20
 [<ffffffff81573d00>] ? __rtnl_unlock+0x20/0x20
 [<ffffffff815901b1>] netlink_rcv_skb+0xa1/0xb0
 [<ffffffff815718c5>] rtnetlink_rcv+0x25/0x40
 [<ffffffff8158fafd>] netlink_unicast+0x19d/0x1f0
 [<ffffffff8158fe2b>] netlink_sendmsg+0x2db/0x360
 [<ffffffff8154c66d>] ? sock_update_netprioidx+0x6d/0x250
 [<ffffffff81544888>] sock_sendmsg+0xf8/0x130
 [<ffffffff81545f9d>] ? sock_recvmsg+0xfd/0x130
 [<ffffffff811745d5>] ? might_fault+0xa5/0xb0
 [<ffffffff8117458c>] ? might_fault+0x5c/0xb0
 [<ffffffff81555266>] ? verify_iovec+0x56/0xd0
 [<ffffffff81545e8e>] __sys_sendmsg+0x42e/0x440
 [<ffffffff811bd612>] ? fget_light+0x62/0x4a0
 [<ffffffff811bd6a0>] ? fget_light+0xf0/0x4a0
 [<ffffffff811bd612>] ? fget_light+0x62/0x4a0
 [<ffffffff81548c59>] sys_sendmsg+0x49/0x90
 [<ffffffff816a74a9>] system_call_fastpath+0x16/0x1b
