From: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Subject: [PATCH net-next 00/15] 6lowpan: Some more bug
	fixes
Date: Tue, 23 Oct 2012 00:09:42 -0400
Message-ID: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

Hello,

This patch serie fixes a few bugs within the 6lowpan modules and prepares the
integration of the serial driver that will be submitted in a subsequent patch serie.
It should apply cleanly on the latest net-next.

Regards,
	Tony Cheneau

Tony Cheneau (15):
  6lowpan: lowpan_is_iid_16_bit_compressable() does not detect
    compressable address correctly
  6lowpan: next header is not properly set upon decompression of a UDP
    header.
  6lowpan: always enable link-layer acknowledgments
  mac802154: turn on ACK when enabled by the upper layers
  6lowpan: use short IEEE 802.15.4 addresses for broadcast destination
  6lowpan: fix first fragment (FRAG1) handling
  6lowpan: store fragment tag values per device instead of net stack
    wide
  6lowpan: obtain IEEE802.15.4 sequence number from the MAC layer
  6lowpan: add a new parameter in sysfs to turn on/off ACK request at
    MAC layer
  6lowpan: use the PANID provided by the device instead of a static
    value
  6lowpan: modify udp compression/uncompression to match the standard
  6lowpan: make memory allocation atomic during 6lowpan header creation
  mac802154: make mem alloc ATOMIC to prevent "scheduling while atomic"
    crashes
  mac802154: remove unnecessary spinlocks
  mac802154: re-introduce MAC primitives required to send/receive
    packets

 net/ieee802154/6lowpan.c  |  144 ++++++++++++++++++++++++++++++++++++---------
 net/ieee802154/6lowpan.h  |   14 +++--
 net/mac802154/mac802154.h |    2 +
 net/mac802154/mac_cmd.c   |   22 +++++++-
 net/mac802154/mib.c       |   33 +++++++----
 net/mac802154/wpan.c      |    4 +-
 6 files changed, 172 insertions(+), 47 deletions(-)

-- 
1.7.8.6


------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_sfd2d_oct
