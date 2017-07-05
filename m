From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next RFC 07/12] net: dsa: Add support for querying supported bridge flags
Date: Wed,  5 Jul 2017 18:36:25 +0300
Message-ID: <1499268990-19251-8-git-send-email-arkadis@mellanox.com>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49180 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751685AbdGEPdb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 11:33:31 -0400
In-Reply-To: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DSA drivers do not support bridge flags offload. Yet, this attribute
should be added in order for the bridge to fail when one tries set a
flag on the port, as explained in commit dc0ecabd6231 ("net: switchdev:
Add support for querying supported bridge flags by hardware").

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
---
 net/dsa/slave.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 7307195..53326ba 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -324,6 +324,9 @@ static int dsa_slave_port_attr_get(struct net_device *dev,
 		attr->u.ppid.id_len = sizeof(ds->index);
 		memcpy(&attr->u.ppid.id, &ds->index, attr->u.ppid.id_len);
 		break;
+	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS_SUPPORT:
+		attr->u.brport_flags_support = 0;
+		break;
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
2.4.11
