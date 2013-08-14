From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCHv2 net-next 0/6] 6lowpan: uncompress of
	addresses fix
Date: Wed, 14 Aug 2013 13:01:42 +0200
Message-ID: <1376478108-3539-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
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

The current implementation to uncompress addresses in a 6lowpan header
is completely broken.

This patch series fixes the parsing of addresses in a 6lowpan header.
It contains a major rewrite of the uncompress address function to parse
the address in a correct way.

Changes since v2:
 - Add tags for net-next
 - Change commit msg in Patch 1/6 that this patch depends for the following
   patches

Alexander Aring (5):
  6lowpan: init ipv6hdr buffer to zero
  6lowpan: introduce lowpan_fetch_skb function
  6lowpan: add function to uncompress multicast addr
  6lowpan: lowpan_uncompress_addr with address_mode
  6lowpan: handle context based source address

David Hauweele (1):
  6lowpan: Fix fragmentation with link-local compressed addresses

 net/ieee802154/6lowpan.c | 284 +++++++++++++++++++++++++++++++----------------
 net/ieee802154/6lowpan.h |  20 +++-
 2 files changed, 203 insertions(+), 101 deletions(-)

-- 
1.8.3.3


------------------------------------------------------------------------------
Get 100% visibility into Java/.NET code with AppDynamics Lite!
It's a free troubleshooting tool designed for production.
Get down to code-level detail for bottlenecks, with <2% overhead. 
Download for free and get started troubleshooting in minutes. 
http://pubads.g.doubleclick.net/gampad/clk?id=48897031&iu=/4140/ostg.clktrk
