From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH 00/18] cleanup: wrapper functions of net_ratelimit() called to simplify code
Date: Tue, 15 Oct 2013 19:44:56 +0800
Message-ID: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Stephen Hemminger" <stephen@networkplumber.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Samuel Ortiz <samuel@sortiz.org>,
	Paul Mackerras <paulus@samba.org>,
	Oliver Neukum <oneukum@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, <netfilter@vger.kernel.org>,
	<netdev@vger.ker
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Macro PRINTR is called only once in nfnetlink_log.c, and it can be 
replaced by wrappe function of net_ratelimit(), so kill it.

Meanwhile, I found many files could use wrappe functions of net_ratelimit()
to simplify, so I did.


Kefeng Wang (18):
  netfilter: cleanup: delete Macro PRINTR
  net: use wrapper functions of net_ratelimit() to simplify code
  rt18187se: use wrapper functions of net_ratelimit() to simplify code
  rt18192e: use wrapper functions of net_ratelimit() to simplify code
  rt18192u: use wrapper functions of net_ratelimit() to simplify code
  net: wireless: use wrapper functions of net_ratelimit() to simplify
    code
  net: ethernet: use wrapper functions of net_ratelimit() to simplify
    code
  atm: use wrapper functions of net_ratelimit() to simplify code
  block: aoe: use wrapper functions of net_ratelimit() to simplify code
  net: peak_usb: use wrapper functions of net_ratelimit() to simplify
    code
  net: hamradio: use wrapper functions of net_ratelimit() to simplify
    code
  net: irda: use wrapper functions of net_ratelimit() to simplify code
  net: ppp: use wrapper functions of net_ratelimit() to simplify code
  net: usb: use wrapper functions of net_ratelimit() to simplify code
  net: xen: use wrapper functions of net_ratelimit() to simplify code
  net: virtio: use wrapper functions of net_ratelimit() to simplify code
  net: vxlan: use wrapper functions of net_ratelimit() to simplify code
  net: wimax: use wrapper functions of net_ratelimit() to simplify code

 drivers/atm/solos-pci.c                            | 20 ++++-----
 drivers/block/aoe/aoenet.c                         |  4 +-
 drivers/net/can/usb/peak_usb/pcan_usb_core.c       | 11 ++---
 drivers/net/ethernet/aeroflex/greth.c              | 16 +++----
 drivers/net/ethernet/alteon/acenic.c               |  3 +-
 drivers/net/ethernet/arc/emac_main.c               |  7 ++--
 drivers/net/ethernet/broadcom/b44.c                |  4 +-
 drivers/net/ethernet/ethoc.c                       |  4 +-
 drivers/net/ethernet/faraday/ftgmac100.c           | 49 +++++++---------------
 drivers/net/ethernet/faraday/ftmac100.c            | 45 ++++++--------------
 drivers/net/ethernet/freescale/fec_mpc52xx.c       |  3 +-
 drivers/net/ethernet/ibm/emac/mal.c                | 15 ++-----
 drivers/net/ethernet/marvell/mv643xx_eth.c         |  6 +--
 drivers/net/ethernet/marvell/pxa168_eth.c          |  8 +---
 drivers/net/ethernet/marvell/sky2.c                | 42 +++++++------------
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |  5 +--
 drivers/net/ethernet/realtek/r8169.c               | 13 +++---
 drivers/net/ethernet/sfc/rx.c                      |  8 ++--
 drivers/net/ethernet/sfc/siena_sriov.c             | 27 ++++--------
 drivers/net/ethernet/ti/davinci_emac.c             |  4 +-
 drivers/net/ethernet/tundra/tsi108_eth.c           | 12 ++----
 drivers/net/hamradio/6pack.c                       |  3 +-
 drivers/net/hamradio/bpqether.c                    |  3 +-
 drivers/net/irda/stir4200.c                        |  3 +-
 drivers/net/ppp/ppp_generic.c                      | 11 +++--
 drivers/net/usb/usbnet.c                           |  4 +-
 drivers/net/virtio_net.c                           |  3 +-
 drivers/net/vxlan.c                                |  3 +-
 drivers/net/wimax/i2400m/netdev.c                  |  3 +-
 drivers/net/wireless/adm8211.c                     |  5 +--
 drivers/net/wireless/ath/carl9170/cmd.c            | 15 +++----
 drivers/net/wireless/ath/carl9170/phy.c            |  7 +---
 drivers/net/wireless/ath/carl9170/rx.c             | 45 ++++++--------------
 drivers/net/wireless/ath/carl9170/usb.c            | 12 ++----
 drivers/net/wireless/hostap/hostap_80211_rx.c      |  8 +---
 drivers/net/wireless/hostap/hostap_80211_tx.c      | 13 ++----
 drivers/net/wireless/hostap/hostap_ap.c            |  6 +--
 drivers/net/wireless/hostap/hostap_hw.c            | 17 +++-----
 drivers/net/wireless/iwlegacy/3945-mac.c           |  4 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |  6 +--
 drivers/net/wireless/iwlwifi/pcie/rx.c             |  7 ++--
 drivers/net/wireless/libertas_tf/cmd.c             |  6 +--
 drivers/net/wireless/mwl8k.c                       |  5 +--
 drivers/net/wireless/orinoco/hermes.c              |  6 +--
 drivers/net/wireless/orinoco/main.c                | 16 +++----
 drivers/net/wireless/orinoco/orinoco_usb.c         |  3 +-
 drivers/net/wireless/p54/p54pci.c                  |  6 +--
 drivers/net/xen-netback/netback.c                  | 21 ++++------
 drivers/net/xen-netfront.c                         | 27 ++++--------
 .../rtl8187se/ieee80211/ieee80211_crypt_ccmp.c     | 16 ++-----
 .../rtl8187se/ieee80211/ieee80211_crypt_tkip.c     | 27 ++++--------
 drivers/staging/rtl8187se/ieee80211/ieee80211_rx.c |  4 +-
 drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c |  7 +---
 drivers/staging/rtl8192e/rtllib_crypt_ccmp.c       | 13 ++----
 drivers/staging/rtl8192e/rtllib_crypt_tkip.c       | 21 +++-------
 drivers/staging/rtl8192e/rtllib_rx.c               |  6 +--
 .../rtl8192u/ieee80211/ieee80211_crypt_ccmp.c      | 17 ++------
 .../rtl8192u/ieee80211/ieee80211_crypt_tkip.c      | 22 +++-------
 drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c  |  7 +---
 drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c  |  4 +-
 net/bridge/br_fdb.c                                |  6 +--
 net/bridge/br_multicast.c                          | 13 ++----
 net/bridge/br_stp_bpdu.c                           | 11 ++---
 net/mac80211/rx.c                                  |  6 +--
 net/netfilter/ipset/ip_set_hash_gen.h              |  3 +-
 net/netfilter/nfnetlink_log.c                      |  5 +--
 66 files changed, 246 insertions(+), 516 deletions(-)

-- 
1.8.2.1
