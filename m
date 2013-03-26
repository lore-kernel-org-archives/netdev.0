From: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Subject: [PATCH v2 net-next 00/12] 6lowpan: Some more
	bug fixes
Date: Mon, 25 Mar 2013 23:59:20 -0400
Message-ID: <1364270372-19430-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

This patchset fixes serious bugs within the 6LoWPAN modules. I wrote a script
(available at [1]) to prove the issues are real.  One can try and see that
without these patches, most of the test fail (e.g. packet dropped by the
receiver or node crashing). With all patches applied, all tests succeed. The
tests themselves are very basic: sending ICMP packets, sending UDP packets,
sending TCP packets, varying size of the packets. This actually triggers some
6LoWPAN specific code, namely fragmentation, packet reassembly and header
compression.

This code passed the checkpatch.pl tool with a few warnings, that I believe
are OK. It should apply cleanly on the latest net-next.

Regards,
	Tony Cheneau

[1]: https://github.com/tcheneau/linux802154-regression-tests

Tony Cheneau (12):
  6lowpan: lowpan_is_iid_16_bit_compressable() does not detect
    compressible address correctly
  6lowpan: next header is not properly set upon decompression of a UDP
    header.
  6lowpan: always enable link-layer acknowledgments
  mac802154: turn on ACK when enabled by the upper layers
  6lowpan: use short IEEE 802.15.4 addresses for broadcast destination
  6lowpan: fix first fragment (FRAG1) handling
  6lowpan: add debug messages for 6LoWPAN fragmentation
  6lowpan: store fragment tag values per device instead of net stack
    wide
  mac802154: re-introduce mac802154_dev_get_dsn()
  6lowpan: obtain IEEE802.15.4 sequence number from the MAC layer
  6lowpan: use the PANID provided by the device instead of a static
    value
  6lowpan: modify udp compression/uncompression to match the standard

 net/ieee802154/6lowpan.c  | 136 +++++++++++++++++++++++++++++++++++++---------
 net/ieee802154/6lowpan.h  |   7 ++-
 net/mac802154/mac802154.h |   1 +
 net/mac802154/mac_cmd.c   |   1 +
 net/mac802154/mib.c       |   9 +++
 net/mac802154/wpan.c      |   2 +
 6 files changed, 127 insertions(+), 29 deletions(-)

-- 
1.7.12.4


------------------------------------------------------------------------------
Own the Future-Intel&reg; Level Up Game Demo Contest 2013
Rise to greatness in Intel's independent game demo contest.
Compete for recognition, cash, and the chance to get your game 
on Steam. $5K grand prize plus 10 genre and skill prizes. 
Submit your demo by 6/6/13. http://p.sf.net/sfu/intel_levelupd2d
