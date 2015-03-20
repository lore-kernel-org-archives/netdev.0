From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 0/3] be2net: patch set
Date: Fri, 20 Mar 2015 06:28:22 -0400
Message-ID: <1426847305-23008-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:20338 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383AbbCTKZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:25:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, this patch set includes 3 bug fixes to the be2net driver.

Patch 1 fixes a vlan isolation issue with VFs. When a VF is placed in
promiscous mode, it could receive packets belonging to any vlan, as
the PF driver grants vlan promisc capability to VFs. The PF
driver now disables the vlan promisc capability for VFs to fix this
problem.

Patch 2 fixes the call to MODIFY_EQ_DELAY FW cmd to not include more
than 8 EQs per cmd. The FW is not capable of handling more than 8 EQs
per cmd.

Patch 3 fixes an EEH error detection issue. On Power platforms,
when an EEH error occurs, the slot disconnect state is more reliably
detected via an MMIO read compared to a config read. So, the error
register reads that occur every second are now done via MMIO.

Pls apply this patch set to the "net" tree. Thanks!

Suresh Reddy (2):
  be2net: restrict MODIFY_EQ_DELAY cmd to a max of 8 EQs
  be2net: use PCI MMIO read instead of config read for errors

Vasundhara Volam (1):
  be2net: Prevent VFs from enabling VLAN promiscuous mode
