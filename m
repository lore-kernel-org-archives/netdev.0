From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] rtnetlink: clean up SR-IOV config interface
Date: Wed, 24 Feb 2010 23:59:56 -0800
Message-ID: <20100225075950.18665.50738.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:60203
	"EHLO qmta13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753318Ab0BYIAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 03:00:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

This patch consists of a few minor cleanups to the SR-IOV
configurion code in rtnetlink.
- Remove unneccesary lock
- Remove unneccesary casts
- Return correct error code for no driver support

These changes are based on comments from Patrick McHardy

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/core/rtnetlink.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 42da96a..4dd4c3c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -930,10 +930,9 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	if (tb[IFLA_VF_MAC]) {
 		struct ifla_vf_mac *ivm;
 		ivm = nla_data(tb[IFLA_VF_MAC]);
-		write_lock_bh(&dev_base_lock);
+		err = -EOPNOTSUPP;
 		if (ops->ndo_set_vf_mac)
 			err = ops->ndo_set_vf_mac(dev, ivm->vf, ivm->mac);
-		write_unlock_bh(&dev_base_lock);
 		if (err < 0)
 			goto errout;
 		modified = 1;
@@ -942,12 +941,11 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	if (tb[IFLA_VF_VLAN]) {
 		struct ifla_vf_vlan *ivv;
 		ivv = nla_data(tb[IFLA_VF_VLAN]);
-		write_lock_bh(&dev_base_lock);
+		err = -EOPNOTSUPP;
 		if (ops->ndo_set_vf_vlan)
 			err = ops->ndo_set_vf_vlan(dev, ivv->vf,
-						   (u16)ivv->vlan,
-						   (u8)ivv->qos);
-		write_unlock_bh(&dev_base_lock);
+						   ivv->vlan,
+						   ivv->qos);
 		if (err < 0)
 			goto errout;
 		modified = 1;
@@ -957,10 +955,9 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	if (tb[IFLA_VF_TX_RATE]) {
 		struct ifla_vf_tx_rate *ivt;
 		ivt = nla_data(tb[IFLA_VF_TX_RATE]);
-		write_lock_bh(&dev_base_lock);
+		err = -EOPNOTSUPP;
 		if (ops->ndo_set_vf_tx_rate)
 			err = ops->ndo_set_vf_tx_rate(dev, ivt->vf, ivt->rate);
-		write_unlock_bh(&dev_base_lock);
 		if (err < 0)
 			goto errout;
 		modified = 1;

