From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Top kernel oopses/warnings for the week of October 7th, 2008
Date: Tue, 07 Oct 2008 12:52:53 -0700
Message-ID: <48EBBE15.9030905@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, NetDev <netdev@vger.kernel.org>,
	linux-acpi <linux-acpi@vger.kernel.org>, tglx@tglx.de,
	Theodore Ts'o <tytso@mit.edu>, linux-ide@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:59224 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753009AbYJGTw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 15:52:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This week, a total of 3340 oopses and warnings have been reported,
compared to 3022 reports in the previous week.
As with last week, this report only covers kernels 2.6.26 and later.



Per file statistics
722	net/sched/sch_generic.c
206	fs/jbd/journal.c
178	external/utrace
131	drivers/base/power/main.c
104	drivers/ata/libata-sff.c
104	include/linux/pagemap.h
96	kernel/timer.c
62	fs/ext3/super.c
61	external/fireglx/binary (P)
61	drivers/usb/serial/usb-serial.c
61	net/core/dev.c


Unsolved issues
===============

Rank 1: dev_watchdog (warning)
	Reported 431 times (1363 total reports)
	Network TX watchdog timeouts for unidentified NICs. 2.6.27-rc7+ will identify the NIC.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog
	The general top 10 distribution over the identified cases is like this:
	
  count |          guilty
-------+---------------------------
    390 | dev_watchdog(sis900)
    114 | dev_watchdog(usbnet)
    102 | dev_watchdog(via-rhine)
     99 | dev_watchdog(8390)
     47 | dev_watchdog(8139too)
     44 | dev_watchdog(orinoco)
     40 | dev_watchdog(r8169)
     26 | dev_watchdog(3c59x)
     17 | dev_watchdog(forcedeth)
     15 | dev_watchdog(fealnx)


Rank 3: journal_update_superblock (warning)
	Reported 202 times (4509 total reports)
	Likely caused by the user removing a USB stick while mounted
	Ted has a patch to fix this; queued for 2.6.28
	This warning was last seen in version 2.6.27-rc8-git4, and first seen in 2.6.24-rc6-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=journal_update_superblock

Rank 4: utrace_control (oops)
	Reported 166 times (1001 total reports)
	[fedora] Fedora merged a broken utrace patch
	This oops was last seen in version 2.6.26.5, and first seen in 2.6.26.1.
	More info: http://www.kerneloops.org/searchweek.php?search=utrace_control

Rank 5: dev_watchdog(sis900) (warning)
	Reported 135 times (390 total reports)
	This warning was last seen in version 2.6.27-rc8-git4, and first seen in 2.6.26-rc4-git2.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(sis900)

Rank 7: lock_page (warning)
	Reported 104 times (150 total reports)
	The hwclock program disables interrupts from userspace, and then hits a pagefault.
	The new diagnostics do a WARN_ON for faults-with-interrupts-off, and trap this.
	This warning was last seen in version 2.6.27-rc8-git7, and first seen in 2.6.27-rc1-git2.
	More info: http://www.kerneloops.org/searchweek.php?search=lock_page

Rank 8: run_timer_softirq (oops)
	Reported 83 times (301 total reports)
	softlockup; likely fixed by the timer cleanups done by Thomas
	This oops was last seen in version 2.6.27-rc1-git4, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=run_timer_softirq

Rank 9: device_pm_add (warning)
	Reported 81 times (323 total reports)
	Drivers with suspect suspend/resume logic; a patch is queued for 2.6.28 to identify
	which drivers are involved.
	This warning was last seen in version 2.6.27-rc4, and first seen in 2.6.26-rc5.
	More info: http://www.kerneloops.org/searchweek.php?search=device_pm_add

Rank 10: ext3_commit_super (warning)
	Reported 58 times (1164 total reports)
	Likely caused by the user removing a USB stick while mounted
	Ted has a fix for this.
	This warning was last seen in version 2.6.27, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=ext3_commit_super

Rank 11: device_suspend (warning)
	Reported 50 times (139 total reports)
	Drivers with suspect suspend/resume logic; a patch is queued for 2.6.28 to identify
	which drivers are involved.
	This warning was last seen in version 2.6.26.5, and first seen in 2.6.26.
	More info: http://www.kerneloops.org/searchweek.php?search=device_suspend

Rank 12: suspend_test_finish (warning)
	Reported 49 times (103 total reports)
	This warning was last seen in version 2.6.27, and first seen in 2.6.27-rc0-git14.
	More info: http://www.kerneloops.org/searchweek.php?search=suspend_test_finish

Rank 13: rs_get_rate (warning)
	Reported 43 times (423 total reports)
	Bug in the Intel IWL wireless drivers
	This warning was last seen in version 2.6.27-rc8-git1, and first seen in 2.6.25-rc2-git5.
	More info: http://www.kerneloops.org/searchweek.php?search=rs_get_rate

Rank 14: dev_watchdog(usbnet) (warning)
	Reported 41 times (114 total reports)
	This warning was last seen in version 2.6.27-rc5-git9, and first seen in 2.6.26.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(usbnet)


Fixed issues
============
Rank 6: ata_sff_hsm_move (oops)
	Reported 104 times (1156 total reports)
	[fixed] redundant WARN_ON; fixed in 9c2676b61a5a4b6d99e65fb2f438fb3914302eda
	This oops was last seen in version 2.6.27-rc2-git1, and first seen in 2.6.25.4.
	More info: http://www.kerneloops.org/searchweek.php?search=ata_sff_hsm_move
