From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 20/21] rocker: Add proper validation of Netlink attributes
Date: Thu, 27 Nov 2014 11:40:25 +0100
Message-ID: <1417084826-9875-21-git-send-email-jiri@resnulli.us>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:47148 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754377AbaK0Kky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 05:40:54 -0500
Received: by mail-wg0-f46.google.com with SMTP id x12so6084460wgg.5
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 02:40:53 -0800 (PST)
In-Reply-To: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
new in v4
---
 drivers/net/ethernet/rocker/rocker.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 61cfdbf..30687bf 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3712,6 +3712,9 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
 	if (afspec) {
 		attr = nla_find_nested(afspec, IFLA_BRIDGE_MODE);
 		if (attr) {
+			if (nla_len(attr) < sizeof(mode))
+				return -EINVAL;
+
 			mode = nla_get_u16(attr);
 			if (mode != BRIDGE_MODE_SWDEV)
 				return -EINVAL;
@@ -3721,6 +3724,9 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
 	if (protinfo) {
 		attr = nla_find_nested(protinfo, IFLA_BRPORT_LEARNING);
 		if (attr) {
+			if (nla_len(attr) < sizeof(u8))
+				return -EINVAL;
+
 			if (nla_get_u8(attr))
 				rocker_port->brport_flags |= BR_LEARNING;
 			else
@@ -3731,6 +3737,9 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
 		}
 		attr = nla_find_nested(protinfo, IFLA_BRPORT_LEARNING_SYNC);
 		if (attr) {
+			if (nla_len(attr) < sizeof(u8))
+				return -EINVAL;
+
 			if (nla_get_u8(attr))
 				rocker_port->brport_flags |= BR_LEARNING_SYNC;
 			else
-- 
1.9.3
