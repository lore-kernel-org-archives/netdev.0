From: Dave Jones <davej@redhat.com>
Subject: kmem_cache_create(nf_conntrack_expect): Cache name already exists.
Date: Tue, 26 Mar 2013 10:18:32 -0400
Message-ID: <20130326141832.GA17701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56388 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932971Ab3CZOSf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 10:18:35 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r2QEIZj9008410
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 10:18:35 -0400
Received: from gelk.kernelslacker.org (ovpn-113-85.phx2.redhat.com [10.3.113.85])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r2QEIYt8020315
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 10:18:34 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.6/8.14.5) with ESMTP id r2QEIWOp026842
	for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 10:18:32 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.6/8.14.6/Submit) id r2QEIWEP026803
	for netdev@vger.kernel.org; Tue, 26 Mar 2013 10:18:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We had a user report this against a 3.6.6 kernel.
Given the uptimes he usually sees on that box, it may be a while before
he gets a chance to see this again if it hasn't been fixed.

Does this look familiar to anyone ?

Mar 21 04:00:12 kernel: [8176848.470356] nf_conntrack version 0.5.0 (16049 buckets, 64196 max)
Mar 21 04:00:12 kernel: [8176848.471261] kmem_cache_create(nf_conntrack_expect): Cache name already exists.
Mar 21 04:00:12 kernel: [8176848.471794] Pid: 32711, comm: modprobe Not tainted 3.6.6-1.fc16.i686 #1
Mar 21 04:00:12 kernel: [8176848.472321] Call Trace:
Mar 21 04:00:12 kernel: [8176848.472959]  [<c0511b44>] kmem_cache_create+0x144/0x190
Mar 21 04:00:12 kernel: [8176848.473684]  [<f7d8b7e8>] nf_conntrack_expect_init+0xe8/0x120 [nf_conntrack]
Mar 21 04:00:12 kernel: [8176848.474358]  [<f7d89b06>] nf_conntrack_init+0xe6/0x320 [nf_conntrack]
Mar 21 04:00:12 kernel: [8176848.475045]  [<f7d8a164>] nf_conntrack_net_init+0x14/0x170 [nf_conntrack]
Mar 21 04:00:12 kernel: [8176848.475732]  [<f7da9000>] ? 0xf7da8fff
Mar 21 04:00:12 kernel: [8176848.476394]  [<c085c1b9>] ops_init+0x39/0x110
Mar 21 04:00:12 kernel: [8176848.477052]  [<c085c41c>] register_pernet_operations+0xcc/0x140
Mar 21 04:00:12 kernel: [8176848.477686]  [<c085c511>] register_pernet_subsys+0x21/0x40
Mar 21 04:00:12 kernel: [8176848.478348]  [<f7da900d>] nf_conntrack_standalone_init+0xd/0x1000 [nf_conntrack]
Mar 21 04:00:12 kernel: [8176848.478965]  [<c0401124>] do_one_initcall+0x34/0x170
Mar 21 04:00:12 kernel: [8176848.479608]  [<f7da9000>] ? 0xf7da8fff
Mar 21 04:00:12 kernel: [8176848.480227]  [<c049977c>] sys_init_module+0xfcc/0x1cf0
Mar 21 04:00:12 kernel: [8176848.480821]  [<c055b73a>] ? mntput_no_expire+0x3a/0x110
Mar 21 04:00:12 kernel: [8176848.481456]  [<c0958f5f>] sysenter_do_call+0x12/0x28

user has a cron job that restarts his firewall setup every morning, and this occurred
during that, while aparently things were low on memory..


Mar 21 04:00:12 modprobe: FATAL: Error inserting iptable_nat (/lib/modules/3.6.6-1.fc16.i686/kernel/net/ipv4/netfilter/iptable_nat.ko): Cannot allocate memory
