From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 04/11] net: dsa: debugfs: add tag_protocol
Date: Mon, 14 Aug 2017 18:22:35 -0400
Message-ID: <20170814222242.10643-5-vivien.didelot@savoirfairelinux.com>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Maxime Hadjinlian <maxime@devialet.com>,
        Chris Healy <cphealy@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Stefan Eichenberger <eichest@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>,
        Juergen Borleis <jbe@pengutronix.de>,
        Tobias Waldekranz <tobias@waldekranz.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40298 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752563AbdHNW1K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 18:27:10 -0400
In-Reply-To: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a debug filesystem "tag_protocol" entry to query the switch tagging
protocol through the .get_tag_protocol operation.

    # cat switch1/tag_protocol
    EDSA

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/debugfs.c | 54 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
index 5607efdb924d..30a732e86161 100644
--- a/net/dsa/debugfs.c
+++ b/net/dsa/debugfs.c
@@ -109,6 +109,55 @@ static int dsa_debugfs_create_file(struct dsa_switch *ds, struct dentry *dir,
 	return 0;
 }
 
+static int dsa_debugfs_tag_protocol_read(struct dsa_switch *ds, int id,
+					 struct seq_file *seq)
+{
+	enum dsa_tag_protocol proto;
+
+	if (!ds->ops->get_tag_protocol)
+		return -EOPNOTSUPP;
+
+	proto = ds->ops->get_tag_protocol(ds);
+
+	switch (proto) {
+	case DSA_TAG_PROTO_NONE:
+		seq_puts(seq, "NONE\n");
+		break;
+	case DSA_TAG_PROTO_BRCM:
+		seq_puts(seq, "BRCM\n");
+		break;
+	case DSA_TAG_PROTO_DSA:
+		seq_puts(seq, "DSA\n");
+		break;
+	case DSA_TAG_PROTO_EDSA:
+		seq_puts(seq, "EDSA\n");
+		break;
+	case DSA_TAG_PROTO_KSZ:
+		seq_puts(seq, "KSZ\n");
+		break;
+	case DSA_TAG_PROTO_LAN9303:
+		seq_puts(seq, "LAN9303\n");
+		break;
+	case DSA_TAG_PROTO_MTK:
+		seq_puts(seq, "MTK\n");
+		break;
+	case DSA_TAG_PROTO_QCA:
+		seq_puts(seq, "QCA\n");
+		break;
+	case DSA_TAG_PROTO_TRAILER:
+		seq_puts(seq, "TRAILER\n");
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static const struct dsa_debugfs_ops dsa_debugfs_tag_protocol_ops = {
+	.read = dsa_debugfs_tag_protocol_read,
+};
+
 static int dsa_debugfs_tree_read(struct dsa_switch *ds, int id,
 				 struct seq_file *seq)
 {
@@ -151,6 +200,11 @@ static int dsa_debugfs_create_switch(struct dsa_switch *ds)
 	if (IS_ERR_OR_NULL(ds->debugfs_dir))
 		return -EFAULT;
 
+	err = dsa_debugfs_create_file(ds, ds->debugfs_dir, "tag_protocol", -1,
+				      &dsa_debugfs_tag_protocol_ops);
+	if (err)
+		return err;
+
 	err = dsa_debugfs_create_file(ds, ds->debugfs_dir, "tree", -1,
 				      &dsa_debugfs_tree_ops);
 	if (err)
-- 
2.14.0
