From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH net-next] etherdevice: Use ether_addr_copy to copy
 an Ethernet address
Date: Wed, 15 Jan 2014 16:07:58 -0800
Message-ID: <1389830878.14001.39.camel@joe-AO722>
References: <1389741527.24849.68.camel@joe-AO722>
	 <20140115.153951.743060257410154565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	linux-arch@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0246.hostedemail.com ([216.40.44.246]:44131 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750952AbaAPAID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 19:08:03 -0500
In-Reply-To: <20140115.153951.743060257410154565.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-15 at 15:39 -0800, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 14 Jan 2014 15:18:47 -0800
> 
> > Some systems can use the normally known u16 alignment of
> > Ethernet addresses to save some code/text bytes and cycles.
> > 
> > This does not change currently emitted code on x86 by gcc 4.8.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> This looks fine, in fact I'll apply it.

OK, good.

There are a couple thousand memcpy(foo, bar, ETH_ALEN)
in the kernel tree that could be converted.

Some will have a small performance improvement for
arm and powerpc.

If you want the ones for net-next net/ now (but not
for batman-adv, that maybe could use a new function like
ether_addr_copy_unaligned) here's a changestat.

Otherwise, I'll wait for the next cycle.

(done via coccinelle)

 net/8021q/vlan.c                          |  2 +-
 net/8021q/vlan_dev.c                      |  6 ++--
 net/appletalk/aarp.c                      | 10 +++---
 net/atm/lec.c                             |  9 ++---
 net/atm/mpc.c                             |  2 +-
 net/bluetooth/bnep/core.c                 | 19 +++++-----
 net/bluetooth/bnep/netdev.c               | 14 ++++----
 net/bridge/br_device.c                    |  4 +--
 net/bridge/br_fdb.c                       |  4 +--
 net/bridge/br_multicast.c                 |  4 +--
 net/bridge/br_netfilter.c                 |  2 +-
 net/bridge/br_stp_if.c                    | 10 +++---
 net/bridge/netfilter/ebt_among.c          |  2 +-
 net/bridge/netfilter/ebt_dnat.c           |  2 +-
 net/bridge/netfilter/ebt_redirect.c       |  6 ++--
 net/bridge/netfilter/ebt_snat.c           |  2 +-
 net/caif/caif_usb.c                       |  4 +--
 net/core/netpoll.c                        |  4 +--
 net/core/pktgen.c                         |  8 ++---
 net/decnet/dn_dev.c                       |  2 +-
 net/decnet/dn_neigh.c                     |  6 ++--
 net/decnet/dn_route.c                     |  6 ++--
 net/dsa/slave.c                           |  2 +-
 net/ethernet/eth.c                        | 18 +++++-----
 net/hsr/hsr_device.c                      |  8 ++---
 net/hsr/hsr_framereg.c                    | 21 +++++------
 net/hsr/hsr_main.c                        |  4 +--
 net/ipv4/netfilter/ipt_CLUSTERIP.c        |  2 +-
 net/mac80211/agg-rx.c                     | 10 +++---
 net/mac80211/agg-tx.c                     | 18 +++++-----
 net/mac80211/cfg.c                        | 34 +++++++++---------
 net/mac80211/debugfs_netdev.c             | 12 +++----
 net/mac80211/ht.c                         | 16 ++++-----
 net/mac80211/ibss.c                       | 14 ++++----
 net/mac80211/iface.c                      | 27 +++++++-------
 net/mac80211/mesh.c                       | 30 ++++++++--------
 net/mac80211/mesh_hwmp.c                  | 32 ++++++++---------
 net/mac80211/mesh_pathtbl.c               | 20 +++++------
 net/mac80211/mesh_plink.c                 |  6 ++--
 net/mac80211/mesh_ps.c                    |  2 +-
 net/mac80211/mlme.c                       | 32 ++++++++---------
 net/mac80211/rx.c                         | 14 ++++----
 net/mac80211/spectmgmt.c                  |  6 ++--
 net/mac80211/sta_info.c                   |  8 ++---
 net/mac80211/tx.c                         | 60 +++++++++++++++----------------
 net/mac80211/util.c                       | 22 ++++++------
 net/mac80211/wpa.c                        |  4 +--
 net/netfilter/ipset/ip_set_bitmap_ipmac.c |  6 ++--
 net/openvswitch/actions.c                 |  4 +--
 net/openvswitch/flow.c                    | 16 ++++-----
 net/openvswitch/flow_netlink.c            | 14 ++++----
 net/tipc/eth_media.c                      |  2 +-
 net/wireless/core.c                       |  2 +-
 net/wireless/ibss.c                       | 11 +++---
 net/wireless/lib80211_crypt_ccmp.c        |  4 +--
 net/wireless/lib80211_crypt_tkip.c        | 18 +++++-----
 net/wireless/mlme.c                       |  2 +-
 net/wireless/nl80211.c                    |  6 ++--
 net/wireless/scan.c                       |  6 ++--
 net/wireless/sme.c                        | 18 +++++-----
 net/wireless/util.c                       | 42 +++++++++++-----------
 net/wireless/wext-compat.c                |  8 ++---
 net/wireless/wext-sme.c                   |  5 +--
 net/wireless/wext-spy.c                   |  8 ++---
 64 files changed, 365 insertions(+), 357 deletions(-)
