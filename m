From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 00/10] use appropriate APIs to get interfaces
Date: Wed, 15 Jan 2014 10:23:35 +0800
Message-ID: <1389752625-23189-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vfalico@redhat.com>, <john.r.fastabend@intel.com>,
	<stephen@networkplumber.org>, <antonio@meshcoding.com>,
	<dmitry.tarnyagin@lockless.no>, <socketcan@hartkopp.net>,
	<johannes@sipsolutions.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:44079 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaAOCYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 21:24:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under rtnl_lock protection, we should use __dev_get_name/index()
rather than dev_get_name()/index() to find interface handlers
because the former interfaces can help us avoid to change interface
reference counter.

v2 changes:
 - Change return value of nl80211_set_wiphy() to 0 in patch #10
   by johannes's suggestion.
 - Add 'Acked-by' into several patches which were acknowledged by
   corresponding maintainers.

Ying Xue (10):
  Drivers: Staging: cxt1e1: use __dev_get_name instead of dev_get_name
    to find interfaces
  bonding: use __dev_get_by_name instead of dev_get_by_name to find
    interface
  eql: use __dev_get_by_name instead of dev_get_by_name to find
    interface
  dcb: use __dev_get_by_name instead of dev_get_by_name to find
    interface
  decnet: use __dev_get_by_index instead of dev_get_by_index to find
    interface
  vxlan: use __dev_get_by_index instead of dev_get_by_index to find
    interface
  batman-adv: use __dev_get_by_index instead of dev_get_by_index to
    find interface
  caif: __dev_get_by_index instead of dev_get_by_index to find
    interface
  can: use __dev_get_by_index instead of dev_get_by_index to find
    interface
  net: nl80211: __dev_get_by_index instead of dev_get_by_index to find
    interface

 drivers/net/bonding/bond_main.c |   49 +++++++++----------
 drivers/net/eql.c               |   95 ++++++++++++++++--------------------
 drivers/net/vxlan.c             |    3 +-
 drivers/staging/cxt1e1/linux.c  |   15 +++---
 net/batman-adv/hard-interface.c |    4 +-
 net/caif/chnl_net.c             |    3 +-
 net/can/gw.c                    |   15 ++----
 net/dcb/dcbnl.c                 |   15 ++----
 net/decnet/dn_route.c           |   10 +---
 net/wireless/nl80211.c          |  102 ++++++++++++++-------------------------
 10 files changed, 124 insertions(+), 187 deletions(-)

-- 
1.7.9.5
