From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next v2 0/6] 802154: some cleanups
	and fixes
Date: Wed, 14 May 2014 17:43:05 +0200
Message-ID: <1400082191-16493-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
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

This series adds some definitions for 802.15.4 header fields that were missing,
changes 6lowpan fragmentation to be aware of security headers and fixes
802.15.4 datagram socket sendmsg(), which was entirely incompliant to date.
Also a few minor changes to mac_cb handling, mark a single-use function static,
and correctly check for EMSGSIZE conditions during wpan_header_create.

Changes since v1:
  * rename mac_cb_alloc to mac_cb_init
  * catch all error cases of sendmsg() instead of only !conn && msg_name
  * redo 6lowpan fragmentation to not clone lower layer headers

---

Phoebe Buckheister (6):
      ieee802154: add definitions for link-layer security and header functions
      mac802154: account for all header parts during wpan header creationg
      ieee802154: change _cb handling slightly
      6lowpan: fix fragmentation
      ieee802154: fix dgram socket sendmsg()
      mac802154: make mac802154_wpan_open static


 include/net/ieee802154.h        |    9 ++
 include/net/ieee802154_netdev.h |   54 ++++++----
 net/ieee802154/6lowpan_rtnl.c   |  207 ++++++++++++++++++++-------------------
 net/ieee802154/dgram.c          |   38 ++++---
 net/ieee802154/header_ops.c     |   52 ++++++++--
 net/mac802154/rx.c              |    2 -
 net/mac802154/wpan.c            |   30 +++---
 7 files changed, 236 insertions(+), 156 deletions(-)



------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
