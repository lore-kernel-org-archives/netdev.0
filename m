From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 00/18] net subsystem various refcounter conversions
Date: Fri, 17 Mar 2017 13:12:41 +0200
Message-ID: <1489749179-12063-1-git-send-email-elena.reshetova@intel.com>
Cc: bridge@lists.linux-foundation.org, linux-x25@vger.kernel.org,
	jhs@mojatatu.com, davem@davemloft.net, yoshfuji@linux-ipv6.org,
	marcel@holtmann.org, linux-decnet-user@lists.sourceforge.net,
	jmorris@namei.org, ralf@linux-mips.org,
	linux-kernel@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	peterz@infradead.org, keescook@chromium.org,
	jchapman@katalix.com, 3chas3@gmail.com,
	linux-hams@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	kaber@trash.net, Elena Reshetova <elena.reshetova@intel.com>,
	johan.hedberg@gmail.com
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This series, for various network subsystem components, replaces atomic_t reference
counters with the new refcount_t type and API (see include/linux/refcount.h).
By doing this we prevent intentional or accidental
underflows or overflows that can led to use-after-free vulnerabilities.

The patches are fully independent and can be cherry-picked separately.
Since we convert all kernel subsystems in the same fashion, resulting
in about 300 patches, we have to group them for sending at least in some
fashion to be manageable. Please excuse the long cc list.

If there are no objections to the patches, please merge them via respective trees.

Elena Reshetova (18):
  net, llc: convert llc_sap.refcnt from atomic_t to refcount_t
  net, l2tp: convert l2tp_tunnel.ref_count from atomic_t to refcount_t
  net, l2tp: convert l2tp_session.ref_count from atomic_t to refcount_t
  net, vxlan: convert vxlan_sock.refcnt from atomic_t to refcount_t
  net, bluetooth: convert rfcomm_dlc.refcnt from atomic_t to refcount_t
  net, decnet: convert dn_fib_info.fib_clntref from atomic_t to
    refcount_t
  net, atm: convert atm_dev.refcnt from atomic_t to refcount_t
  net, atm: convert lec_arp_table.usage from atomic_t to refcount_t
  net, atm: convert in_cache_entry.use from atomic_t to refcount_t
  net, atm: convert eg_cache_entry.use from atomic_t to refcount_t
  net, bridge: convert net_bridge_vlan.refcnt from atomic_t to
    refcount_t
  net, calipso: convert calipso_doi.refcount from atomic_t to refcount_t
  net, sched: convert Qdisc.refcnt from atomic_t to refcount_t
  net, lapb: convert lapb_cb.refcnt from atomic_t to refcount_t
  net, ipx: convert ipx_interface.refcnt from atomic_t to refcount_t
  net, ipx: convert ipx_route.refcnt from atomic_t to refcount_t
  net, netrom: convert nr_neigh.refcount from atomic_t to refcount_t
  net, netrom: convert nr_node.refcount from atomic_t to refcount_t

 drivers/net/vxlan.c            | 10 +++++-----
 include/linux/atmdev.h         |  7 ++++---
 include/net/bluetooth/rfcomm.h |  8 +++++---
 include/net/calipso.h          |  4 ++--
 include/net/dn_fib.h           |  5 +++--
 include/net/ipx.h              | 13 +++++++------
 include/net/lapb.h             |  3 ++-
 include/net/llc.h              |  6 +++---
 include/net/netrom.h           | 13 +++++++------
 include/net/sch_generic.h      |  3 ++-
 include/net/vxlan.h            |  2 +-
 net/atm/lec.c                  |  6 +++---
 net/atm/lec_arpc.h             |  2 +-
 net/atm/mpoa_caches.c          | 26 +++++++++++++-------------
 net/atm/mpoa_caches.h          |  5 +++--
 net/atm/proc.c                 |  2 +-
 net/atm/resources.c            |  2 +-
 net/bluetooth/rfcomm/core.c    |  4 ++--
 net/bridge/br_private.h        |  3 ++-
 net/bridge/br_vlan.c           |  8 ++++----
 net/decnet/dn_fib.c            |  6 +++---
 net/ipv6/calipso.c             | 12 ++++++------
 net/ipx/af_ipx.c               |  6 +++---
 net/ipx/ipx_proc.c             |  2 +-
 net/ipx/ipx_route.c            |  2 +-
 net/l2tp/l2tp_core.c           | 16 ++++++++--------
 net/l2tp/l2tp_core.h           | 13 +++++++------
 net/l2tp/l2tp_debugfs.c        |  5 ++---
 net/l2tp/l2tp_ppp.c            |  2 +-
 net/lapb/lapb_iface.c          |  6 +++---
 net/llc/llc_core.c             |  2 +-
 net/netrom/nr_route.c          |  6 +++---
 net/sched/sch_api.c            |  8 ++++----
 net/sched/sch_generic.c        |  8 ++++----
 34 files changed, 118 insertions(+), 108 deletions(-)

-- 
2.7.4
