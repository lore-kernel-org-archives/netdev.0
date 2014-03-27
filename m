From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH v2 0/6] netpoll: Cleanups and fixes
Date: Thu, 27 Mar 2014 15:35:20 -0700
Message-ID: <87vbuzqnh3.fsf_-_@x220.int.ebiederm.org>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:57061 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756166AbaC0Wfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 18:35:33 -0400
In-Reply-To: <87iorcgh5d.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 17 Mar 2014 23:22:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This should be a small set of safe cleanups and fixes to netpoll.

The fixes are vlan headers are now always inserted when needed, and
napi polling is always avoided when network devices are closed.

There are a bunch of little cleanups removing unnecessary code, fixing
function naming, not taking unnecessary locks and removing general
silliness.

Eric W. Biederman (6):
      netpoll: Remove gfp parameter from __netpoll_setup
      netpoll: Only call ndo_start_xmit from a single place
      netpoll: Move rx enable/disable into __dev_close_many
      netpoll: Rename netpoll_rx_enable/disable to netpoll_poll_disable/enable
      netpoll: Remove strong unnecessary assumptions about skbs
      netpoll: Respect NETIF_F_LLTX

 drivers/net/bonding/bond_main.c |  6 +--
 drivers/net/team/team.c         | 16 ++++----
 include/linux/netdevice.h       |  8 +++-
 include/linux/netpoll.h         | 10 ++---
 net/8021q/vlan_dev.c            |  7 ++--
 net/bridge/br_device.c          | 15 ++++---
 net/bridge/br_if.c              |  2 +-
 net/bridge/br_private.h         |  4 +-
 net/core/dev.c                  | 17 +++-----
 net/core/netpoll.c              | 91 +++++++++++++++++++++++------------------
 10 files changed, 91 insertions(+), 85 deletions(-)
