From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: [PATCH 0/6] 802.15.4 and 6LoWPAN Buffering
	Fixes
Date: Tue,  2 Apr 2013 14:47:55 -0400
Message-ID: <1364928481-1813-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

These patches fix an issue in the 802.15.4 code where the output buffer
(which prior to this patchset is just a workqueue) can grow to an arbitrary
size.  This is basically fixed as follows:

1. Use netif_stop_queue() and netif_wake_queue() to stop and start the
transmit queue, preventing packets from piling up without bound on the
mac802154 workqueue.

2.  Increase the default tx_buffer_len for mac802154 (wpan) devices from 10
to 300, enabling Qdisc to work properly on the transmit queue.

Additionally the following related issues are fixed:

1. Handle dev_queue_xmit() return values properly in the 6LoWPAN code (and
return the proper errors to the higher layers).  This will cause the higher
layers to retry later if the mac802154 queue is full.

2. Fix the retry of transmit failures in mac802154.

Alan Ott (6):
  mac802154: Immediately retry sending failed packets
  mac802154: Move xmit_attemps to stack
  mac802154: Use netif flow control
  mac802154: Increase tx_buffer_len
  6lowpan: handle dev_queue_xmit error code properly
  6lowpan: return the dev_queue_xmit() return value from lowpan_xmit()

 net/ieee802154/6lowpan.c |  4 ++--
 net/mac802154/tx.c       | 34 ++++++++++++++++++++++++----------
 net/mac802154/wpan.c     |  2 +-
 3 files changed, 27 insertions(+), 13 deletions(-)

-- 
1.7.11.2


------------------------------------------------------------------------------
Minimize network downtime and maximize team effectiveness.
Reduce network management and security costs.Learn how to hire 
the most talented Cisco Certified professionals. Visit the 
Employer Resources Portal
http://www.cisco.com/web/learning/employer_resources/index.html
