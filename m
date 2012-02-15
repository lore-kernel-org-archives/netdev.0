From: Danny Kukawka <danny.kukawka-2YacvwyR+KOzQB+pC5nmwQ@public.gmane.org>
Subject: [RESEND][PATCH v2 0/2] Part 2: handle addr_assign_type
	for random addresses
Date: Wed, 15 Feb 2012 17:45:38 +0100
Message-ID: <1329324340-13461-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
	Eilon Greenstein <eilong-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, Roger Luethi <rl-7uj+XXdSDtwfv37vnLkPlQ@public.gmane.org>,
	Daniele Venzano <venza-aa24p/qCTT1g9hUCZPvPmw@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	Danny Kukawka <dkukawka-l3A5Bk7waGM@public.gmane.org>, James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>,
	"bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org Chris Metcalf" <cmetcalf-kv+TWInifGbQT0dZR+AlfA@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Hartley Sweeten <hsweeten-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Steve Glendinning <stev
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

The second part of my patch series to fix the handling of 
addr_assign_type for random MAC addresses. This contains the
trival changes from random_ether_addr() to new
eth_hw_addr_random() and code to reset the state to 
NET_ADDR_PERM as soon as the MAC get changed via 
.ndo_set_mac_address where eth_mac_addr wasn't used.

Resend due to send with too long recipients list. Sorry!
Thanks to Joe Perches for the hint.

Danny Kukawka (2):
  net: replace random_ether_addr() with eth_hw_addr_random()
  net: use eth_hw_addr_random() and reset addr_assign_type

 drivers/net/dummy.c                               |    3 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c   |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |    2 +-
 drivers/net/ethernet/cadence/macb.c               |    2 +-
 drivers/net/ethernet/calxeda/xgmac.c              |    3 ++-
 drivers/net/ethernet/cirrus/ep93xx_eth.c          |    2 +-
 drivers/net/ethernet/davicom/dm9000.c             |    2 +-
 drivers/net/ethernet/dnet.c                       |    2 +-
 drivers/net/ethernet/faraday/ftgmac100.c          |    2 +-
 drivers/net/ethernet/faraday/ftmac100.c           |    2 +-
 drivers/net/ethernet/marvell/pxa168_eth.c         |    3 ++-
 drivers/net/ethernet/micrel/ks8842.c              |    3 ++-
 drivers/net/ethernet/micrel/ks8851.c              |    3 ++-
 drivers/net/ethernet/micrel/ks8851_mll.c          |    1 +
 drivers/net/ethernet/microchip/enc28j60.c         |    3 ++-
 drivers/net/ethernet/mipsnet.c                    |    2 +-
 drivers/net/ethernet/natsemi/macsonic.c           |    2 +-
 drivers/net/ethernet/nvidia/forcedeth.c           |    3 ++-
 drivers/net/ethernet/rdc/r6040.c                  |    2 +-
 drivers/net/ethernet/sis/sis900.c                 |    2 +-
 drivers/net/ethernet/smsc/smsc911x.c              |    3 ++-
 drivers/net/ethernet/smsc/smsc9420.c              |    5 ++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 +-
 drivers/net/ethernet/tile/tilepro.c               |    3 ++-
 drivers/net/ethernet/toshiba/tc35815.c            |    2 +-
 drivers/net/ethernet/via/via-rhine.c              |    2 +-
 drivers/net/ifb.c                                 |    2 +-
 drivers/net/macvlan.c                             |    3 ++-
 drivers/net/team/team.c                           |    3 ++-
 drivers/net/tun.c                                 |    2 +-
 drivers/net/usb/smsc75xx.c                        |    2 +-
 drivers/net/usb/smsc95xx.c                        |    2 +-
 drivers/net/veth.c                                |    4 ++--
 drivers/net/virtio_net.c                          |    2 +-
 drivers/net/wan/hdlc_fr.c                         |    2 +-
 drivers/net/wan/hdlc_raw_eth.c                    |    2 +-
 net/bridge/br_device.c                            |    3 ++-
 net/ipv4/ip_gre.c                                 |    2 +-
 net/l2tp/l2tp_eth.c                               |    2 +-
 net/openvswitch/vport-internal_dev.c              |    3 ++-
 40 files changed, 55 insertions(+), 41 deletions(-)

-- 
1.7.8.3
