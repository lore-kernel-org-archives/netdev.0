From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Oops/Warning report of the week of July 4th 2008
Date: Fri, 04 Jul 2008 15:14:46 -0700
Message-ID: <486EA0D6.2040504@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Dave Jones <davej@redhat.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:63076 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752361AbYGDWPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 18:15:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This week, a total of 3541 oopses and warnings have been reported,
compared to 3794 reports in the previous week.


The stats look very similar to last week; Fedora released a 2.6.25.9 based
kernel upgrade, which led to a new sighting (at rank 12): the rt25xx wireless
driver is calling flush_workqueue() with a NULL parameter in some cases.
There has been a lot of thrash about the last report with regard to inclusion of wireless.git
into the Fedora kernel rpms. As an observer I can say that it's both a blessing and a bog.
It's a blessing in that this allows bugs to show up early before wireless.git hits mainline
(as an example: this is the third or fourth fedora rpm upgrade in a row that showed new and exciting
oopses/warnings due to rt25xx... as a result of very active development). It's a bog in that
it may expose users to not-quite-ready code. So far it seems the Fedora kernel maintainers are happy
enough with the overall balance that they continue the practice.


Per file statistics
548	external/madwifi/wrapper (P)
264	drivers/parport/procfs.c
258	external/madwifi/binary (P)
249	fs/sysfs/dir.c
241	drivers/net/wireless/b43/main.c
229	fs/jbd/journal.c
154	external/fireglx/binary (P)
91	kernel/time/tick-broadcast.c
64	drivers/ata/libata-core.c
58	fs/ext3/super.c
43	kernel/workqueue.c
41	net/mac80211/tx.c


Reports seen on non-tainted kernels
===================================
Rank 2: parport_device_proc_register (warning)
	Reported 264 times (2002 total reports)
	Duplicate /proc registration in the parport driver
	This warning was last seen in version 2.6.26-rc8-git2, and first seen in 2.6.24-rc5.
	More info: http://www.kerneloops.org/searchweek.php?search=parport_device_proc_register

Rank 4: b43_generate_noise_sample (warning)
	Reported 239 times (1124 total reports)
	[fixed] too strict WARN_ON in b43 driver
	This got fixed recently, and Fedora will have a backport of the fix soon as well.
	This warning was last seen in version 2.6.26-rc4-git5, and first seen in 2.6.25.3.
	More info: http://www.kerneloops.org/searchweek.php?search=b43_generate_noise_sample

Rank 5: sysfs_add_one (warning)
	Reported 238 times (1835 total reports)
	Duplicate sysfs registration warning; USB hubs and USB audio are the most implicated parts
	This warning was last seen in version 2.6.26-rc3, and first seen in 2.6.24-rc6.
	More info: http://www.kerneloops.org/searchweek.php?search=sysfs_add_one

Rank 6: journal_update_superblock (warning)
	Reported 226 times (1482 total reports)
	Caused by the user removing a USB stick while mounted
	(This isn't a corner case as much as it used to; todays desktop systems auto-mount USB sticks)
	This warning was last seen in version 2.6.26, and first seen in 2.6.24-rc6-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=journal_update_superblock

Rank 8: tick_broadcast_oneshot_control (softlockup)
	Reported 91 times (634 total reports)
	Some interaction between tickless and systems with an AMD CPU and an ATI chipset
	(eg only seen on systems that both have an AMD cpu and an ATI chipset)
	Current suspicion is some kind of time-warp problem that causes the softlockup code
	to trigger incorrectly
	This softlockup was last seen in version 2.6.25.9, and first seen in 2.6.24-rc4.
	More info: http://www.kerneloops.org/searchweek.php?search=tick_broadcast_oneshot_control

Rank 10: ata_hsm_move (warning)
	Reported 63 times (233 total reports)
	Linus just merged patches to get better diagnostics for this case
	This warning was last seen in version 2.6.25.9, and first seen in 2.6.25-rc9-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=ata_hsm_move

Rank 11: ext3_commit_super (warning)
	Reported 53 times (356 total reports)
	Likely caused by the user removing a USB stick while mounted
	This warning was last seen in version 2.6.26-rc8-git2, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=ext3_commit_super

Rank 12: flush_workqueue (oops)
	Reported 39 times
	Bug in the rt25xx driver passing NULL to the flush_workqueue() function
	This oops was last seen in version 2.6.25.9, and first seen in 2.6.25.9.
	More info: http://www.kerneloops.org/searchweek.php?search=flush_workqueue

Rank 13: ieee80211_master_start_xmit (warning)
	Reported 38 times (183 total reports)
	This used to be specific to the iwlwifi drivers, but now shows up with various other
	drivers as well
	This warning was last seen in version 2.6.25.9, and first seen in 2.6.25.4.
	More info: http://www.kerneloops.org/searchweek.php?search=ieee80211_master_start_xmit

Only seen on tainted kernels
============================
Rank 1: ath_dynamic_sysctl_register (warning)
	Reported 462 times (4375 total reports)
	[external] Bug in the proprietary madwifi driver
	warning only shows up in tainted kernels
	This warning was last seen in version 2.6.25.9, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=ath_dynamic_sysctl_register

Rank 3: init_ath_hal (warning)
	Reported 258 times (2658 total reports)
	[external] Bug in the proprietary madwifi driver
	warning only shows up in tainted kernels
	This warning was last seen in version 2.6.25.9, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=init_ath_hal

Rank 7: firegl_ioctl (warning)
	Reported 124 times (997 total reports)
	[external] Bug in the proprietary fireglx driver
	warning only shows up in tainted kernels
	This warning was last seen in version 2.6.25.10, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=firegl_ioctl

Rank 9: ath_sysctl_register (warning)
	Reported 86 times (1109 total reports)
	[external] Bug in the proprietary madwifi driver
	warning only shows up in tainted kernels
	This warning was last seen in version 2.6.25.9, and first seen in 2.6.24-rc4-git4.
	More info: http://www.kerneloops.org/searchweek.php?search=ath_sysctl_register

