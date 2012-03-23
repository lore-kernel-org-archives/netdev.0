From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 22 Mar 2012 23:32:54 -0400 (EDT)
Message-ID: <20120322.233254.1188476332090385245.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) L2TP doesn't get autoloaded when you try to open an L2TP socket
   due to a missing module alias, fix from Benjamin LaHaise.

2) Netlabel and RDS should propagate gfp flags given to them by
   callers, fixes from Dan Carpeneter.

3) Recursive locking fix in usbnet wasn't bulletproof and can result
   in objects going away mid-flight due to races, fix from
   Ming Lei.

4) Fix up some confusion about a bool module parameter in netfilter's
   iptable_filter and ip6table_filter, from Rusty Russell.

5) If SKB recycling is used via napi_reuse_skb() we end up with
   different amounts of headroom reserved than we had at the original
   SKB allocation.  Fix from Eric Dumazet.

6) Fix races in TG3 driver ring refilling, from Michael Chan.

7) We have callbacks for IPSEC replay notifiers, but some call sites
   were not using the ops method and instead were calling one of the
   implementations directly.  Oops.  Fix from Steffen Klassert.

8) Fix IP address validation properly in the bonding driver, the previous
   fix only works with netlink where the subnet mask and IP address are
   changed in one atomic operation.  When 'ifconfig' ioctls are used
   the IP address and the subnet mask are changed in two distinct
   operations.  Fix from Andy Gospodarek.

9) Provide a sky2 module operation to work around power management
   issues with some BIOSes.  From Stephen Hemminger.

Please pull, thanks a lot.

The following changes since commit 4f5b1affdda3e0c48cac674182f52004137b0ffc:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/lliubbo/blackfin (2012-03-22 18:20:02 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Andy Gospodarek (1):
      bonding: remove entries for master_ip and vlan_ip and query devices instead

Benjamin LaHaise (1):
      l2tp: enable automatic module loading for l2tp_ppp

Dan Carpenter (2):
      netlabel: use GFP flags from caller instead of GFP_ATOMIC
      RDS: use gfp flags from caller in conn_alloc()

Eric Dumazet (1):
      net: fix napi_reuse_skb() skb reserve

Michael Chan (2):
      tg3: Fix RSS ring refill race condition
      cnic: Fix parity error code conflict

Oliver Neukum (1):
      usbnet: consider device busy at each recieved packet

Rusty Russell (1):
      netfilter: remove forward module param confusion.

Steffen Klassert (2):
      xfrm: Remove unused xfrm_state from xfrm_state_check_space
      xfrm: Access the replay notify functions via the registered callbacks

stephen hemminger (1):
      sky2: override for PCI legacy power management

tom.leiming@gmail.com (2):
      usbnet: increase URB reference count before usb_unlink_urb
      usbnet: don't clear urb->dev in tx_complete

 drivers/net/bonding/bond_main.c           |   82 +++++-----------------------
 drivers/net/bonding/bonding.h             |   18 ++++++-
 drivers/net/ethernet/broadcom/cnic.c      |   12 +++--
 drivers/net/ethernet/broadcom/cnic_defs.h |   28 +---------
 drivers/net/ethernet/broadcom/cnic_if.h   |    4 +-
 drivers/net/ethernet/broadcom/tg3.c       |   25 ++++++++-
 drivers/net/ethernet/broadcom/tg3.h       |    1 +
 drivers/net/ethernet/marvell/sky2.c       |   11 ++++
 drivers/net/usb/usbnet.c                  |   11 ++++-
 drivers/scsi/bnx2fc/bnx2fc_constants.h    |    1 +
 drivers/scsi/bnx2i/57xx_iscsi_constants.h |    1 +
 net/core/dev.c                            |    3 +-
 net/ipv4/devinet.c                        |    1 +
 net/ipv4/netfilter/iptable_filter.c       |    9 +---
 net/ipv6/netfilter/ip6table_filter.c      |    9 +---
 net/l2tp/l2tp_ppp.c                       |    1 +
 net/netlabel/netlabel_kapi.c              |    2 +-
 net/rds/ib_cm.c                           |    2 +-
 net/rds/iw_cm.c                           |    2 +-
 net/rds/loop.c                            |    2 +-
 net/xfrm/xfrm_output.c                    |    4 +-
 net/xfrm/xfrm_replay.c                    |    6 +-
 22 files changed, 104 insertions(+), 131 deletions(-)
