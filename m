From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next v4 0/4] ieee802154: clean up
	header handling
Date: Tue,  4 Mar 2014 15:34:44 +0100
Message-ID: <1393943688-24221-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This series of patches cleans up handling of 802.15.4 headers in ieee802154 and
mac802154. Particularly, it introduces new functions to read and modify headers
and removes the address fields in the skb cb block in favour of these
functions. This set also fixes a bug that caused parts of an 802.15.4 header to
be delivered to dgram sockets in userspace due to misparsed headers, and moves
mac frame sequence number generation from upper layers into the netdev that
actually handles them.

---

Changes since v3:
 * turned a misplaced && into the & it was supposed to be
Changes since v2:
 * Formatting
Changes since v1:
 * Tested-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
 * trivial checkpatch issues. The "/*\n" in a copyright header was kept for
   consistency, some macro definition lines over 80 characters for readability


Phoebe Buckheister (4):
      ieee802154: add generic header handling routines
      mac802154: use new header ops in wpan devices
      ieee802154: remove addresses from mac_cb
      ieee802154: remove seq member of mac_cb


 include/net/ieee802154.h        |   15 ++
 include/net/ieee802154_netdev.h |   52 +++++-
 include/net/mac802154.h         |    1 +
 net/ieee802154/6lowpan_rtnl.c   |   13 +-
 net/ieee802154/Makefile         |    3 +-
 net/ieee802154/dgram.c          |    6 +-
 net/ieee802154/header_ops.c     |  328 +++++++++++++++++++++++++++++++++++++
 net/ieee802154/reassembly.c     |    5 +-
 net/mac802154/wpan.c            |  343 +++++++++++----------------------------
 9 files changed, 495 insertions(+), 271 deletions(-)



------------------------------------------------------------------------------
Subversion Kills Productivity. Get off Subversion & Make the Move to Perforce.
With Perforce, you get hassle-free workflows. Merge that actually works. 
Faster operations. Version large binaries.  Built-in WAN optimization and the
freedom to use Git, Perforce or both. Make the move to Perforce.
http://pubads.g.doubleclick.net/gampad/clk?id=122218951&iu=/4140/ostg.clktrk
