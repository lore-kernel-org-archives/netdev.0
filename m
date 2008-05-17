From: Dave Jones <davej@codemonkey.org.uk>
Subject: huge failed atomic allocation in dccp.
Date: Sat, 17 May 2008 18:20:27 -0400
Message-ID: <20080517222027.GB31440@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from testure.choralone.org ([194.9.77.134]:33709 "EHLO
	testure.choralone.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbYEQWTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 18:19:43 -0400
Received: from davej by testure.choralone.org with local (Exim 4.69)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1JxUlP-0001CR-Ss
	for netdev@vger.kernel.org; Sat, 17 May 2008 23:20:27 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This strikes me as somewhat bizarre..

modprobe: page allocation failure. order:10, mode:0x20
Pid: 10505, comm: modprobe Not tainted 2.6.25-14.fc9.x86_64 #1

Call Trace:
 [<ffffffff8107ee4c>] __alloc_pages+0x351/0x371
 [<ffffffff8109fc0d>] ? sysfs_slab_alias+0x41/0x81
 [<ffffffff81097d90>] alloc_pages_current+0x100/0x109
 [<ffffffff8107e1ac>] __get_free_pages+0xe/0x4d
 [<ffffffff881010bd>] :dccp:dccp_init+0xbd/0x3a5
 [<ffffffff81057627>] sys_init_module+0x193f/0x1a87
 [<ffffffff810a4c90>] ? do_sync_read+0xe7/0x12d
 [<ffffffff81205eab>] ? release_sock+0x0/0xaf
 [<ffffffff8106d543>] ? audit_syscall_entry+0x126/0x15a
 [<ffffffff81013073>] ? syscall_trace_enter+0xb5/0xb9
 [<ffffffff8100c052>] tracesys+0xd5/0xda

An order 10 GFP_ATOMIC allocation failing shouldn't really be surprising.
The hash sizing in dccp_init seems to cope with this situation
by trying successively smaller values, but this will cause
spew to the logs whilst it's doing that.

	Dave

-- 
http://www.codemonkey.org.uk
