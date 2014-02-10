From: David Miller <davem@davemloft.net>
Subject: Latest version of zero-copy fix
Date: Mon, 10 Feb 2014 15:21:50 -0800 (PST)
Message-ID: <20140210.152150.574073124161003333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ryao@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56782 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440AbaBJXVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 18:21:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


So now the patch only tests is_vmalloc_addr(), did you test this
version with the situation that triggers the given backtrace?

[<ffffffff814878ce>] p9_virtio_zc_request+0x45e/0x510
[<ffffffff814814ed>] p9_client_zc_rpc.constprop.16+0xfd/0x4f0
[<ffffffff814839dd>] p9_client_read+0x15d/0x240
[<ffffffff811c8440>] v9fs_fid_readn+0x50/0xa0
[<ffffffff811c84a0>] v9fs_file_readn+0x10/0x20
[<ffffffff811c84e7>] v9fs_file_read+0x37/0x70
[<ffffffff8114e3fb>] vfs_read+0x9b/0x160
[<ffffffff81153571>] kernel_read+0x41/0x60
[<ffffffff810c83ab>] copy_module_from_fd.isra.34+0xfb/0x180

This is reading from v9fs into a module address.

It's going generate the same backtrace with your fix.

I don't think the situation was sufficiently explained to Linus.  In
fact, I didn't see the above backtrace mentioned at all.
