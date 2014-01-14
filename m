From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 00/10] use appropriate APIs to get interfaces
Date: Tue, 14 Jan 2014 15:40:59 +0800
Message-ID: <1389685269-18600-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vfalico@redhat.com>, <john.r.fastabend@intel.com>,
	<stephen@networkplumber.org>, <antonio@meshcoding.com>,
	<dmitry.tarnyagin@lockless.no>, <socketcan@hartkopp.net>,
	<johannes@sipsolutions.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Under rtnl_lock protection, we should use __dev_get_name/index()
rather than dev_get_name()/index() to find interface handlers
because the former interfaces can help us avoid to change interface
reference counter.

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
 drivers/net/eql.c               |   95 ++++++++++++++++---------------------
 drivers/net/vxlan.c             |    3 +-
 drivers/staging/cxt1e1/linux.c  |   15 +++---
 net/batman-adv/hard-interface.c |    4 +-
 net/caif/chnl_net.c             |    3 +-
 net/can/gw.c                    |   15 ++----
 net/dcb/dcbnl.c                 |   15 ++----
 net/decnet/dn_route.c           |    6 +--
 net/wireless/nl80211.c          |  100 ++++++++++++++-------------------------
 10 files changed, 123 insertions(+), 182 deletions(-)

-- 
1.7.9.5
