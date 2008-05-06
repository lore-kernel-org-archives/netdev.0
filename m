From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 06 May 2008 02:33:54 -0700 (PDT)
Message-ID: <20080506.023354.19323725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36202
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755078AbYEFJdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 05:33:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


More fixes, as usual:

1) When DCCP socket option feature length is invalid, return
   real error code to userspace instead of "1".  From Chris
   Wright.

2) IRDA + !PNP driver build fixes from Ingo.

3) lapbeth leaks netdevice references, leading to module unload
   etc. hangs

4) Fix NIU device probing regression.

5) Two classifier actions fixes from Jamal Hadi Salim.

6) Fix tree handling in HTB classifier, from Jarek Poplawski.

7) Kill build warnings in IPSEC when auditing is disabled.
   From Marcin Slusarz.

8) Several device leak and double-free fixes from Pavel Emelyanov.
   These cure the cases where the driver registered a destructor
   that freed the device, but would then again free it anyways.

9) Get rid of open coded references to route metrics, use existing
   helper functions.

10 IWLWIFI should be a tristate, from Adrian Bunk.

Please pull, thanks a lot!

The following changes since commit f37f2c62a28e848e06399ea2f9be1e098212625c:
  Bernard Pidoux (1):
        rose: Wrong list_lock argument in rose_node seqops

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adrian Bunk (1):
      iwlwifi: make IWLWIFI a tristate

Chris Wright (1):
      dccp: return -EINVAL on invalid feature length

David S. Miller (3):
      lapbeth: Release ->ethdev when unregistering device.
      niu: Fix probing regression for maramba on-board chips.
      Revert "atm: Do not free already unregistered net device."

Ingo Molnar (2):
      irda: fix !PNP support in drivers/net/irda/nsc-ircc.c
      irda: fix !PNP support for drivers/net/irda/smsc-ircc2.c

Jamal Hadi Salim (2):
      net_cls_act: Make act_simple use of netlink policy.
      net_cls_act: act_simple dont ignore realloc code

Jarek Poplawski (1):
      sch_htb: remove from event queue in htb_parent_to_leaf()

Johannes Berg (1):
      net: Fix useless comment reference loop.

Marcin Slusarz (1):
      xfrm: convert empty xfrm_audit_* macros to functions

Pavel Emelyanov (5):
      bridge: Net device leak in br_add_bridge().
      bridge: Consolidate error paths in br_add_bridge().
      mac80211: Do not free net device after it is unregistered.
      atm: Do not free already unregistered net device.
      atm: Bad locking on br2684_devs modifications.

Satoru SATOH (2):
      ip: Make use of the inline function dst_metric_locked()
      ip: Use inline function dst_metric() instead of direct access to dst->metric[]

 drivers/net/irda/nsc-ircc.c          |    6 ++++
 drivers/net/irda/smsc-ircc2.c        |    5 +++-
 drivers/net/niu.c                    |   11 +++++---
 drivers/net/wan/lapbether.c          |    1 +
 drivers/net/wireless/iwlwifi/Kconfig |    3 +-
 include/net/ip.h                     |    2 +-
 include/net/xfrm.h                   |   48 ++++++++++++++++++++++++++++-----
 net/atm/br2684.c                     |    4 +-
 net/bridge/br_if.c                   |   12 +++++---
 net/core/skbuff.c                    |    4 ++-
 net/dccp/feat.c                      |    2 +-
 net/decnet/dn_route.c                |   12 ++++----
 net/ipv4/route.c                     |   18 ++++++------
 net/ipv4/tcp_input.c                 |   15 +++++-----
 net/ipv6/route.c                     |    6 ++--
 net/mac80211/main.c                  |    7 +++-
 net/sched/act_simple.c               |   45 +++++++++++++++----------------
 net/sched/sch_htb.c                  |    8 ++++-
 18 files changed, 132 insertions(+), 77 deletions(-)
