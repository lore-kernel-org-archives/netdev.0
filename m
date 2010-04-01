From: Roland Dreier <rdreier@cisco.com>
Subject: Any ideas about a crash on reboot with igb and intel_iommu?
Date: Thu, 01 Apr 2010 11:13:47 -0700
Message-ID: <adabpe3f3c4.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>
To: netdev@vger.kernel.org, iommu@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:24264 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754563Ab0DASNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 14:13:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

I've been asked to help debug a strange crash, and I'm wondering if
anyone has seen something similar.  The setup is a bit awkward because
this is happening in manufacturing burn-in and we have not reproduced it
in the lab yet, so my ability to do specific experiments is still
limited.

Anyway, we have a fairly standard two-socket Xeon server product that
passes all tests with Nehalem CPUs.  However, when we use Westmere CPUs
(which also requires a new BIOS of course), some fraction of the systems
are crashing during burn-in, which basically runs a cycle where it runs
CPU and memory stress tests and then reboots the system for the next
round of tests.  The crash is happening on reboot, and unfortunately I
only have a bunch of pictures of the traceback output, but we've seen
multiple cases where the system is crashing with a traceback like:

  rb_erase
  __free_iova
  flush_unmaps
  intel_unmap_page
  igb_clean_rx_ring
  igb_down
  igb_close
  __igb_shutdown
  igb_shutdown
  pci_device_shutdown
  device_shutdown
  kernel_restart_prepare
  kernel_restart
  sys_reboot

The newest kernel they've been able to try is 2.6.30.9, but from looking
at the kernel changelogs for igb and intel_iommu at least, I don't see
anything particularly promising that was fixed since then.

One other data point is that enabling the BIOS option "maximize memory
under 4GB" (which apparently just allocates less space for PCI BARs
below 4GB) seems to make this crash go away again.

Anyway, does this tickle anyone's memory?  I'm trying to get a better
handle on things, but if this has been seen before, I'd sure love to
skip some of the pain of debugging this.

Thanks,
  Roland
-- 
Roland Dreier <rolandd@cisco.com> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
