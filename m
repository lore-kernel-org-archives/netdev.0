From: Djalal Harouni <tixxdz@opendz.org>
Subject: Re: [PATCH] net: reference the ipv4 sysctl table header
Date: Tue, 27 Mar 2012 00:21:23 +0100
Message-ID: <20120326232123.GB29626@dztty>
References: <20120326222359.GB28123@dztty>
 <m1mx73rn7t.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from numidia.opendz.org ([98.142.220.152]:47998 "EHLO
	numidia.opendz.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300Ab2CZXRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 19:17:45 -0400
Content-Disposition: inline
In-Reply-To: <m1mx73rn7t.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 26, 2012 at 03:50:30PM -0700, Eric W. Biederman wrote:
> Djalal Harouni <tixxdz@opendz.org> writes:
> 
> > I've been analysing some kmemleak reports of an internal module, and
> > found that there are false positive reports of unreferenced objects.
> >
> > The following patch is just a clean up for one of those false positives,
> > this is for the /proc/sys/net/ipv4 sysctl table.
> > As I've said there are other reports but don't know if it is worth to
> > write patches for them.
> 
> So the problem here is that you register a sysctl and don't keep a
> pointer to the returned sysctl_header?  So kmemleak complains?
Right.

> I would expect the other sysctl data structures to have such a pointer,
> so I don't know why kmemleak would complain.
> 
> Does my recent sysctl rewrite affect when this kmemleak is reported?
Actually yes, after a recent pull (which includes your recent sysctl work),
some of these false positive reports started to appear.


Anyway they seem false positive ones, since keeping a reference to
sysctl_header as in my previous (ugly) patch will quiet the last two ones.

unreferenced object 0xffff88003dc17c70 (size 192):
  comm "swapper/0", pid 0, jiffies 4294667341 (age 86.781s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff819b5d05>] kmemleak_alloc+0x25/0x50
    [<ffffffff81154203>] __kmalloc+0x133/0x240
    [<ffffffff811dc9b7>] __register_sysctl_paths+0x127/0x1d0
    [<ffffffff811dca76>] register_sysctl_paths+0x16/0x20
    [<ffffffff811dca93>] register_sysctl_table+0x13/0x20
    [<ffffffff820cbe55>] sysctl_init+0x10/0x14
    [<ffffffff820d6633>] proc_sys_init+0x2f/0x31
    [<ffffffff820d6410>] proc_root_init+0xa5/0xa7
    [<ffffffff820b5c39>] start_kernel+0x35c/0x38a
    [<ffffffff820b5321>] x86_64_start_reservations+0x131/0x136
    [<ffffffff820b5413>] x86_64_start_kernel+0xed/0xf4
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff88003d65c000 (size 96):
  comm "swapper/0", pid 0, jiffies 4294667341 (age 86.782s)
  hex dump (first 32 bytes):
    60 86 1c 82 ff ff ff ff 00 00 00 00 01 00 00 00  `...............
    01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff819b5d05>] kmemleak_alloc+0x25/0x50
    [<ffffffff81154203>] __kmalloc+0x133/0x240
    [<ffffffff811dc1f2>] __register_sysctl_table+0x52/0x520
    [<ffffffff811dc7ac>] register_leaf_sysctl_tables+0xec/0x1b0
    [<ffffffff811dc77c>] register_leaf_sysctl_tables+0xbc/0x1b0
    [<ffffffff811dc77c>] register_leaf_sysctl_tables+0xbc/0x1b0
    [<ffffffff811dc9e9>] __register_sysctl_paths+0x159/0x1d0
    [<ffffffff811dca76>] register_sysctl_paths+0x16/0x20
    [<ffffffff811dca93>] register_sysctl_table+0x13/0x20
    [<ffffffff820cbe55>] sysctl_init+0x10/0x14
    [<ffffffff820d6633>] proc_sys_init+0x2f/0x31
    [<ffffffff820d6410>] proc_root_init+0xa5/0xa7
    [<ffffffff820b5c39>] start_kernel+0x35c/0x38a
    [<ffffffff820b5321>] x86_64_start_reservations+0x131/0x136
    [<ffffffff820b5413>] x86_64_start_kernel+0xed/0xf4
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff88003d65ddd0 (size 96):
  comm "swapper/0", pid 0, jiffies 4294667341 (age 86.782s)
  hex dump (first 32 bytes):
    00 86 1c 82 ff ff ff ff 00 00 00 00 01 00 00 00  ................
    01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff819b5d05>] kmemleak_alloc+0x25/0x50
    [<ffffffff81154203>] __kmalloc+0x133/0x240
    [<ffffffff811dc1f2>] __register_sysctl_table+0x52/0x520
    [<ffffffff811dc7ac>] register_leaf_sysctl_tables+0xec/0x1b0
    [<ffffffff811dc77c>] register_leaf_sysctl_tables+0xbc/0x1b0
    [<ffffffff811dc9e9>] __register_sysctl_paths+0x159/0x1d0
    [<ffffffff811dca76>] register_sysctl_paths+0x16/0x20
    [<ffffffff811dca93>] register_sysctl_table+0x13/0x20
    [<ffffffff820cbe55>] sysctl_init+0x10/0x14
    [<ffffffff820d6633>] proc_sys_init+0x2f/0x31
    [<ffffffff820d6410>] proc_root_init+0xa5/0xa7
    [<ffffffff820b5c39>] start_kernel+0x35c/0x38a
    [<ffffffff820b5321>] x86_64_start_reservations+0x131/0x136
    [<ffffffff820b5413>] x86_64_start_kernel+0xed/0xf4
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff88003bc41090 (size 96):
  comm "swapper/0", pid 1, jiffies 4294669841 (age 84.299s)
  hex dump (first 32 bytes):
    c0 be ae 82 ff ff ff ff 00 00 00 00 01 00 00 00  ................
    01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff819b5d05>] kmemleak_alloc+0x25/0x50
    [<ffffffff81154203>] __kmalloc+0x133/0x240
    [<ffffffff811dc1f2>] __register_sysctl_table+0x52/0x520
    [<ffffffff811dca3d>] __register_sysctl_paths+0x1ad/0x1d0
    [<ffffffff811dca76>] register_sysctl_paths+0x16/0x20
    [<ffffffff820ef4d6>] sysctl_core_init+0x17/0x38
    [<ffffffff810001cd>] do_one_initcall+0x3d/0x170
    [<ffffffff820b563c>] kernel_init+0xd9/0x15f
    [<ffffffff819e1194>] kernel_thread_helper+0x4/0x10
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff88003bc40ee8 (size 96):
  comm "swapper/0", pid 1, jiffies 4294669854 (age 84.294s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff819b5d05>] kmemleak_alloc+0x25/0x50
    [<ffffffff81154203>] __kmalloc+0x133/0x240
    [<ffffffff811dc9b7>] __register_sysctl_paths+0x127/0x1d0
    [<ffffffff811dca76>] register_sysctl_paths+0x16/0x20
    [<ffffffff820f0c82>] ip_static_sysctl_init+0x17/0x1b
    [<ffffffff820f187f>] inet_init+0xbe/0x2dd
    [<ffffffff810001cd>] do_one_initcall+0x3d/0x170
    [<ffffffff820b563c>] kernel_init+0xd9/0x15f
    [<ffffffff819e1194>] kernel_thread_helper+0x4/0x10
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff88003cd27090 (size 96):
  comm "swapper/0", pid 1, jiffies 4294669854 (age 84.294s)
  hex dump (first 32 bytes):
    c0 dc ae 82 ff ff ff ff 00 00 00 00 01 00 00 00  ................
    01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff819b5d05>] kmemleak_alloc+0x25/0x50
    [<ffffffff81154203>] __kmalloc+0x133/0x240
    [<ffffffff811dc1f2>] __register_sysctl_table+0x52/0x520
    [<ffffffff811dc7ac>] register_leaf_sysctl_tables+0xec/0x1b0
    [<ffffffff811dc77c>] register_leaf_sysctl_tables+0xbc/0x1b0
    [<ffffffff811dc9e9>] __register_sysctl_paths+0x159/0x1d0
    [<ffffffff811dca76>] register_sysctl_paths+0x16/0x20
    [<ffffffff820f0c82>] ip_static_sysctl_init+0x17/0x1b
    [<ffffffff820f187f>] inet_init+0xbe/0x2dd
    [<ffffffff810001cd>] do_one_initcall+0x3d/0x170
    [<ffffffff820b563c>] kernel_init+0xd9/0x15f
    [<ffffffff819e1194>] kernel_thread_helper+0x4/0x10
    [<ffffffffffffffff>] 0xffffffffffffffff


Thanks.

-- 
tixxdz
http://opendz.org
