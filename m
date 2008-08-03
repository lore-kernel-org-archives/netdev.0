From: Arjan van de Ven <arjan@infradead.org>
Subject: Warning when unloading the nf_conntack module (regression?)
Date: Sun, 3 Aug 2008 14:37:30 -0700
Message-ID: <20080803143730.7747e9a8@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40195 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756079AbYHCVhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 17:37:31 -0400
Received: from c-71-193-193-226.hsd1.or.comcast.net ([71.193.193.226] helo=localhost.localdomain)
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1KPlFu-0002Ah-VS
	for netdev@vger.kernel.org; Sun, 03 Aug 2008 21:36:47 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The warning below started showing up on kerneloops.org in the top 20 and it appears to
be new in 2.6.27-rc (e.g. a regression)...

It happens when nf_conntrack is rmmod'd


The reports:
http://www.kerneloops.org/search.php?search=nf_conntrack_acct_fini

The warning:

WARNING: at kernel/sysctl.c:1966 unregister_sysctl_table+0xcc/0x103()

Modules : nf_conntrack(-)

Call Trace:
 [<ffffffff81043bc8>] warn_on_slowpath+0x65/0x98
 [<ffffffff8104abdf>] unregister_sysctl_table+0xcc/0x103
 [<ffffffffa0306655>] nf_conntrack_acct_fini+0x15/0x23 [nf_conntrack]
 [<ffffffffa03018a1>] nf_conntrack_cleanup+0x84/0x86 [nf_conntrack]
 [<ffffffffa0306944>] nf_conntrack_standalone_fini+0x40/0x42 [nf_conntrack] 
 [<ffffffff810700d0>] sys_delete_module+0x202/0x263
 [<ffffffff8101034a>] system_call_fastpath+0x16/0x1b


-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
