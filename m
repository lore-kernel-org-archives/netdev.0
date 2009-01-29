From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH v2 0/4] virtio_net: Add MAC and VLAN filtering
Date: Thu, 29 Jan 2009 16:05:02 -0700
Message-ID: <20090129230502.2672.87669.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:36575 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbZA2XHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 18:07:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds infrastructure for a new control virtqueue and
makes use of it to support set_rx_mode, unicast and multicast address
lists, and supporting a hypervisor based VLAN filter.  The goal is to
make the virtio-net device support more of the features of a physical
NIC and allow the hypervisor to discard packets we don't want.

This version incorporates suggestions from Rusty.  The MAC filter table
size is now managed by the hypervisor.  We treat it as inifinite and
rely on the hypervisor to fall back to promiscuous or all-multi mode
as their resources allow.  The point that made this finally sink in
as the right way to go was the idea of bonding directly to a NIC and
using this interface to manipulate a hardware filter (I hope someone
is working on that in QEMU/KVM).  I've also changed the send_command()
function to return bool.  I'm not completely sure it's everything
you're looking for Rusty, but it does seem cleaner.  Let me know if
this is closer to what you're thinking.  Thanks,

Alex

---

Alex Williamson (4):
      virtio_net: Add support for VLAN filtering in the hypervisor
      virtio_net: Add a MAC filter table
      virtio_net: Add a set_rx_mode interface
      virtio_net: Add a virtqueue for outbound control commands


 drivers/net/virtio_net.c   |  198 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |   61 ++++++++++++++
 2 files changed, 256 insertions(+), 3 deletions(-)

-- 
Alex Williamson
