From: Ingo Molnar <mingo@elte.hu>
Subject: e1000e regression (interface hang) with latest -git
Date: Wed, 21 Jan 2009 11:28:40 +0100
Message-ID: <20090121102840.GA24967__27970.2061707669$1232533859$gmane$org@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
To: linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, e1000-devel@lists.sourceforge.net,
	net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:41361 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754511AbZAUK27 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2009 05:28:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've got a Nehalem testbox that developed a new e1000e problem in this 
merge window: after a few minutes of uptime the network interface goes 
dead - no rx and no tx. If i ifdown/ifup the interface it comes back. If i 
wait too long then even ifdown/ifup does not help anymore - only a reboot.

Other e1000e using testboxes i have are working just fine - so the problem 
is specific to this hw.

Is this a known problem?

I have this hw:

 01:00.0 Ethernet controller: Intel Corporation 82575EB Gigabit Network Connection (rev 02)
 01:00.1 Ethernet controller: Intel Corporation 82575EB Gigabit Network Connection (rev 02)

If this is a new problem, what kind of other info do you need from me to 
debug and fix this?

I started seeing this very early in the merge window, so candidates would 
be one of these early commits:

eb14f01: Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6
cb7b48f: igb/e1000e: Naming interrupt vectors
5b9ab2e: Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6
e243455: e1000e: check return code from NVM accesses and fix bank detection
a20e4cf: e1000e: fix incorrect link status when switch module pulled
8452759: e1000e: store EEPROM version number to prevent unnecessary NVM reads
0285c8d: e1000e: cosmetic newline in debug message
5c48ef3: e1000e: sync change flow control variables with ixgbe
8f12fe8: e1000e: link up/down messages must follow a specific format
75eb0fa: e1000e: ESB2 config after link up
438b365: e1000e: check return of pci_save_state
1605927: e1000e: update comments listing supported parts for each MAC family
63dcf3d: e1000e: 82571 check for link fix on 82571 serdes
5aa49c8: e1000e: commit speed/duplex changes for m88 PHY
005cbdf: e1000e: disable correctable errors for quad ports while going to D3
0082982: netdev: add more functions to netdevice ops
651c246: e1000e: convert to net_device_ops
198d6ba: Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6
6ea7ae1: e1000e: enable ECC correction on 82571 silicon
4cf1653: netdevice: safe convert to netdev_priv() #part-2
babcda7: drivers/net: Kill now superfluous ->last_rx stores.
7c510e4: net: convert more to %pM

If you suspect a specific list of commits i can test their revert. (But 
the box is a slow booter and the problem can take up to 15 minutes to 
trigger so i'd rather not spend half a day bisecting it, if it can be 
avoided.)

Thanks,

	Ingo
