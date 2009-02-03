From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH v4 0/4] virtio_net: Add MAC and VLAN filtering
Date: Tue, 03 Feb 2009 12:25:50 -0700
Message-ID: <20090203192550.2678.14498.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:35613 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755694AbZBCT2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 14:28:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds infrastructure for a new control virtqueue and
makes use of it to support set_rx_mode, unicast and multicast address
lists, and supporting a hypervisor based VLAN filter.  The goal is to
make the virtio-net device support more of the features of a physical
NIC and allow the hypervisor to discard packets we don't want.  These
patches are intended for 2.6.30.

This is the 4th and hopefully final revision, incorporating a few
more tweaks from Rusty.  I've renamed VIRTIO_NET_MAX_CTRL_ARGS to
VIRTNET_SEND_COMMAND_SG_MAX and moved it into the c file.  I've
added the flexible 2-dimensional array to virtio_net_ctrl_mac and
cleaned up the code to use it.  I've retained the single scatterlist
parameter and out/in counts for virtnet_send_command() since the
current sg interface doesn't faciliate merging terminated sg[]s
together.  However, this is an internal virtio_net API and can
easily be refined over time, the key is the separate sg entries
for unicast/multicast MACs for the hypervisor ABI.  Thanks,

Alex

---

Alex Williamson (4):
      virtio_net: Add support for VLAN filtering in the hypervisor
      virtio_net: Add a MAC filter table
      virtio_net: Add a set_rx_mode interface
      virtio_net: Add a virtqueue for outbound control commands


 drivers/net/virtio_net.c   |  168 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |   66 +++++++++++++++++
 2 files changed, 231 insertions(+), 3 deletions(-)

-- 
Alex Williamson
