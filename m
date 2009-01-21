From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: e1000e regression (interface hang) with latest -git
Date: Wed, 21 Jan 2009 09:35:16 -0800
Message-ID: <8DD2590731AB5D4C9DBF71A877482A900DABEA6F__6663.37303487143$1232559432$gmane$org@orsmsx509.amr.corp.intel.com>
References: <20090121102840.GA24967@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
To: Ingo Molnar <mingo@elte.hu>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@i
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:13983 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753074AbZAURfS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 12:35:18 -0500
In-Reply-To: <20090121102840.GA24967@elte.hu>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Ingo Molnar [mailto:mingo@elte.hu]
>Sent: Wednesday, January 21, 2009 2:29 AM
>To: linux-kernel@vger.kernel.org; Kirsher, Jeffrey T; Brandeburg, Jesse;
>Allan, Bruce W; Waskiewicz Jr, Peter P; e1000-devel@lists.sourceforge.net;
>netdev@vger.kernel.org
>Cc: Rafael J. Wysocki
>Subject: e1000e regression (interface hang) with latest -git
>
>
>I've got a Nehalem testbox that developed a new e1000e problem in this
>merge window: after a few minutes of uptime the network interface goes
>dead - no rx and no tx. If i ifdown/ifup the interface it comes back. If i
>wait too long then even ifdown/ifup does not help anymore - only a reboot.
>
>Other e1000e using testboxes i have are working just fine - so the problem
>is specific to this hw.
>
>Is this a known problem?
>
>I have this hw:
>
> 01:00.0 Ethernet controller: Intel Corporation 82575EB Gigabit Network
>Connection (rev 02)
> 01:00.1 Ethernet controller: Intel Corporation 82575EB Gigabit Network
>Connection (rev 02)
>
>If this is a new problem, what kind of other info do you need from me to
>debug and fix this?
>
>I started seeing this very early in the merge window, so candidates would
>be one of these early commits:
>
>eb14f01: Merge branch 'master' of
>master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6
>cb7b48f: igb/e1000e: Naming interrupt vectors
>5b9ab2e: Merge branch 'master' of
>master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6
>e243455: e1000e: check return code from NVM accesses and fix bank
>detection
>a20e4cf: e1000e: fix incorrect link status when switch module pulled
>8452759: e1000e: store EEPROM version number to prevent unnecessary NVM
>reads
>0285c8d: e1000e: cosmetic newline in debug message
>5c48ef3: e1000e: sync change flow control variables with ixgbe
>8f12fe8: e1000e: link up/down messages must follow a specific format
>75eb0fa: e1000e: ESB2 config after link up
>438b365: e1000e: check return of pci_save_state
>1605927: e1000e: update comments listing supported parts for each MAC
>family
>63dcf3d: e1000e: 82571 check for link fix on 82571 serdes
>5aa49c8: e1000e: commit speed/duplex changes for m88 PHY
>005cbdf: e1000e: disable correctable errors for quad ports while going to
>D3
>0082982: netdev: add more functions to netdevice ops
>651c246: e1000e: convert to net_device_ops
>198d6ba: Merge branch 'master' of
>master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6
>6ea7ae1: e1000e: enable ECC correction on 82571 silicon
>4cf1653: netdevice: safe convert to netdev_priv() #part-2
>babcda7: drivers/net: Kill now superfluous ->last_rx stores.
>7c510e4: net: convert more to %pM
>
>If you suspect a specific list of commits i can test their revert. (But
>the box is a slow booter and the problem can take up to 15 minutes to
>trigger so i'd rather not spend half a day bisecting it, if it can be
>avoided.)
>
>Thanks,
>
>	Ingo

82575EB is not supported by e1000e, it is supported by igb.  Are you sure that is the correct device?  Please send the system log and output of:

# for dev in `lspci | grep Ethernet | awk ' { print $1 } '`; do lspci -s $dev -vvv -n; done


