From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 1/2] caif: remove wrong dev_net_set() call
Date: Mon, 26 Jan 2015 22:28:13 +0100
Message-ID: <1422307694-10079-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, dmitry.tarnyagin@lockless.no,
	arvid.brodin@alten.se, alex.aring@gmail.com,
	linux-wpan@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:41142 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420AbbAZV2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 16:28:38 -0500
In-Reply-To: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

src_net points to the netns where the netlink message has been received=
=2E This
netns may be different from the netns where the interface is created (b=
ecause
the user may add IFLA_NET_NS_[PID|FD]). In this case, src_net is the li=
nk netns.

It seems wrong to override the netns in the newlink() handler because i=
f it
was not already src_net, it means that the user explicitly asks to crea=
te the
netdevice in another netns.

CC: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
CC: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
=46ixes: 8391c4aab1aa ("caif: Bugfixes in CAIF netdevice for close and =
flow control")
=46ixes: c41254006377 ("caif-hsi: Add rtnl support")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/caif/caif_hsi.c | 1 -
 net/caif/chnl_net.c         | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 5e40a8b68cbe..b3b922adc0e4 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -1415,7 +1415,6 @@ static int caif_hsi_newlink(struct net *src_net, =
struct net_device *dev,
=20
 	cfhsi =3D netdev_priv(dev);
 	cfhsi_netlink_parms(data, cfhsi);
-	dev_net_set(cfhsi->ndev, src_net);
=20
 	get_ops =3D symbol_get(cfhsi_get_ops);
 	if (!get_ops) {
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 4589ff67bfa9..67a4a36febd1 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -470,7 +470,6 @@ static int ipcaif_newlink(struct net *src_net, stru=
ct net_device *dev,
 	ASSERT_RTNL();
 	caifdev =3D netdev_priv(dev);
 	caif_netlink_parms(data, &caifdev->conn_req);
-	dev_net_set(caifdev->netdev, src_net);
=20
 	ret =3D register_netdevice(dev);
 	if (ret)
--=20
2.2.2
