From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next-2.6 0/8] bonding: Fixes and updates
Date: Sat, 17 May 2008 21:10:06 -0700
Message-ID: <12110838143907-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:57148 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124AbYEREKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 00:10:25 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4I471kN026867
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 00:07:01 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4I4AF0W097396
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 22:10:20 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4I4AF6g004526
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 22:10:15 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Eight patches for bonding; these apply to net-next-2.6.  This
patch set supersedes the previously posted set of 2 ARP monitor changes
(those are included here).

	1- Convert to msecs_to_jiffies instead of doing math to compute
monitor rearm time.  This is cleaner, and fixes an infinite loop.

	2- Remove test for bonding master having an IP address in the ARP
monitor.  Removing this test permits the ARP monitor to run when bonding
is under some virtual device, such as Xen.  Changes the way some ARP
probes look, but is not a loss of functionality.

	3- Remove redundant argument from bond_create.  It once was used
for something, but now is not.

	4- Relax _safe interations.  Some list interations are fine
without using the _safe versions.

	5- Remove unneeded list_empty checks.  Self explanatory.

	6- Optionally send multiple gratuitous ARPs during failover.  Adds
a configurable parameter to specify the number of grat ARPs to send.
Intended for use with IPoIB.

	7- Refactor ARP monitor for active-backup mode.  Split the current
monolithic function into three: inspection, commit, and probe.  Done
primarily to get RTNL semantics right for next patch.  This could have
been done via conditional locking (as miimon was), but this feels like a
cleaner solution.

	8- Add a "follow" option to fail_over_mac.  This causes the
bonding master to take the MAC of the first slave, but not program the
other slaves with that MAC address.  During failover, the MAC moves to the
new currently active slave.  For multiport devices that can't handle
having all ports set to the same MAC (but still want the benefits of the
bond's MAC not changing during failover).

	Patches are against net-next-2.6.  Please apply.

	Also, I'll be unavailable next week (which is unfortunate timing,
but I didn't want these to wait another week), so if there's discussion
that comes up, I'll answer and revise as needed when I return.

	Thanks,

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
