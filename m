From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH 0/5] virtio_net: Add MAC and VLAN filtering
Date: Fri, 16 Jan 2009 14:13:12 -0700
Message-ID: <20090116211312.22836.34331.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, markmc@redhat.com, kvm@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series enables setting the virtio-net device MAC address, adds
infrastructure for the new control virtqueue, and makes use of it
to support set_rx_mode, unicast and multicast address lists, and
supporting a hypervisor based VLAN filter.  The goal is to make the
virtio-net device support more of the features of a physical NIC and
allow the hypervisor to discard packets we're not interested in.

This version incorporates the review comments from Mark McLoughlin,
specifically, much improved comments and commit logs, verifying the
functionality of host not providing a MAC address, moving communication
structs into virtio_net.h, adding warnings when things don't work, and
making the strings grep'able.  I've left the class/cmd split in the
control header rather than consolidating it into a single value, I'm
hoping I've made sufficient arguments for that.  Also, I left the
error return rather than a BUG_ON in send_command because I can't
conditionally enable set_rx_mode as it's in a const struct.  Instead,
I've changed the caller to avoid the issue.  Please comment and/or
apply.  Thanks,

Alex

---

Alex Williamson (5):
      virtio_net: Add support for VLAN filtering in the hypervisor
      virtio_net: Add a MAC filter table
      virtio_net: Add a set_rx_mode interface
      virtio_net: Add a virtqueue for outbound control commands
      virtio_net: Allow setting the MAC address of the NIC


 drivers/net/virtio_net.c   |  224 ++++++++++++++++++++++++++++++++++++++++++--
 include/linux/virtio_net.h |   61 ++++++++++++
 2 files changed, 275 insertions(+), 10 deletions(-)

-- 
Alex Williamson
