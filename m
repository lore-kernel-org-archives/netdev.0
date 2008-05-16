From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Top kernel oopses/warnings for the week of May 16th 2008
Date: Fri, 16 May 2008 09:41:31 -0700
Message-ID: <482DB93B.2080100@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:15125 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762212AbYEPQlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 12:41:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The http://www.kerneloops.org website collects kernel oops and
warning reports from various mailing lists and bugzillas as well as
with a client users can install to auto-submit oopses.
Below is a top 10 list of the oopses collected in the last 7 days.
(Reports prior to 2.6.23 have been omitted in collecting the top 10)

This week, a total of 1617 oopses and warnings have been reported,
compared to 452 reports in the previous week. This sharp increase
is due to Fedora 9 being released, which includes the automatic
collection client.


Per file statistics
-------------------
743	kernel/sysctl.c
113	fs/buffer.c
76	fs/sysfs/dir.c
38	kernel/spinlock.c
22	fs/inotify.c
21	kernel/sysctl_check.c (P)
21	net/core/sock.c
18	fs/file_table.c
17	mm/page_alloc.c
15	lib/iomap.c


Bug of the week
---------------
Not in the top 10 (but barely not so), but upcoming fast is a bug that has a very
distinct pattern.
The backtraces are at http://www.kerneloops.org/searchweek.php?search=fput

The pattern is that the kernel gets an invalid pointer passed to fput(),
coming down from a select() system call done by the "wpa_supplicant" program.
The fact that it is ONLY wpa_supplicant implicates the wireless/network stack.
Another observation is that this only happens with 64 bit kernels, even though
a large portion of the users uses 32 bit kernels. This implies that this is a 64-bit
type of bug. It appears that the top 32 bit of the pointers is getting corrupted
(the bottom part at least looks valid).



Top 10 reported bugs
--------------------

Rank 1: __register_sysctl_paths
	Reported 741 times (1254 total reports)
	Duplicate /proc registration. Bugs in madwifi but also in the parport driver
	This oops was last seen in version 2.6.25.3, and first seen in 2.6.25-rc3.
	More info: http://www.kerneloops.org/searchweek.php?search=__register_sysctl_paths

Rank 2: mark_buffer_dirty
	Reported 110 times (306 total reports)
	EXT3 bug while hot-removing a USB device
	This oops was last seen in version 2.6.25.3, and first seen in 2.6.24-rc6.
	More info: http://www.kerneloops.org/searchweek.php?search=mark_buffer_dirty

Rank 3: sysfs_add_one
	Reported 67 times (272 total reports)
	Adding duplicate sysfs files... seems to be mostly around USB so all in GregKH's park
	This oops was last seen in version 2.6.26-rc2, and first seen in 2.6.24-rc6.
	More info: http://www.kerneloops.org/searchweek.php?search=sysfs_add_one

Rank 4: _spin_unlock_irqrestore
	Reported 38 times (130 total reports)
	Mostly "softlockups" coming out of idle. This could well be mostly hardware issues;
	idle is the most harsh thing in terms of voltage/current swings.
	This oops was last seen in version 2.6.25.3, and first seen in 2.6.22-rc1.
	More info: http://www.kerneloops.org/searchweek.php?search=_spin_unlock_irqrestore

Rank 5: ieee80211_stop_tx_ba_session
	Reported 36 times (56 total reports)
	Seems to be caused by the 4965 driver
	This oops was last seen in version 2.6.25.3, and first seen in 2.6.25-rc7-git6.
	More info: http://www.kerneloops.org/searchweek.php?search=ieee80211_stop_tx_ba_session

Rank 6: nouveau_gpuobj_ref_del
	Reported 22 times (40 total reports)
	Bug in the out-of-tree nouveau driver
	This oops was last seen in version 2.6.25, and first seen in 2.6.25-rc4.
	More info: http://www.kerneloops.org/searchweek.php?search=nouveau_gpuobj_ref_del

Rank 7: set_dentry_child_flags
	Reported 22 times (741 total reports)
	Bug in the 2.6.24 inotify code that got exposed by KDE4 and got fixed in 2.6.25
	This oops was last seen in version 2.6.24.4, and first seen in 2.6.24-rc8-git4.
	More info: http://www.kerneloops.org/searchweek.php?search=set_dentry_child_flags

Rank 8: sysctl_check_lookup
	Reported 21 times (239 total reports)
	Bug in the proprietary madwifi driver
	Oops only shows up in tainted kernels
	This oops was last seen in version 2.6.24.5, and first seen in 2.6.24-rc5.
	More info: http://www.kerneloops.org/searchweek.php?search=sysctl_check_lookup

Rank 9: sk_free
	Reported 19 times (80 total reports)
	VMWare driver bug
	Oops only shows up in tainted kernels
	This oops was last seen in version 2.6.25.3, and first seen in 2.6.23.9.
	More info: http://www.kerneloops.org/searchweek.php?search=sk_free

Rank 10: __alloc_pages
	Reported 16 times (31 total reports)
	Sleeping allocation in interrupt context, some in netlink, some in the nv sata driver
	This oops was last seen in version 2.6.25.3, and first seen in 2.6.18-rc1.
	More info: http://www.kerneloops.org/searchweek.php?search=__alloc_pages

