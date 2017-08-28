From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 08/10] net: dsa: debugfs: add port mdb
Date: Mon, 28 Aug 2017 15:17:46 -0400
Message-ID: <20170828191748.19492-9-vivien.didelot@savoirfairelinux.com>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a debug filesystem "mdb" entry to query a port's hardware MDB
entries through the .port_mdb_dump switch operation.

This is really convenient to query directly the hardware or inspect DSA
or CPU links, since these ports are not exposed to userspace.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/debugfs.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
index 59c09a67bc23..bed8e1d5cfe1 100644
--- a/net/dsa/debugfs.c
+++ b/net/dsa/debugfs.c
@@ -135,6 +135,20 @@ static const struct dsa_debugfs_ops dsa_debugfs_fdb_ops = {
 	.read = dsa_debugfs_fdb_read,
 };
 
+static int dsa_debugfs_mdb_read(struct dsa_switch *ds, int id,
+				struct seq_file *seq)
+{
+	if (!ds->ops->port_mdb_dump)
+		return -EOPNOTSUPP;
+
+	/* same callback as for FDB dump */
+	return ds->ops->port_mdb_dump(ds, id, dsa_debugfs_fdb_dump_cb, seq);
+}
+
+static const struct dsa_debugfs_ops dsa_debugfs_mdb_ops = {
+	.read = dsa_debugfs_mdb_read,
+};
+
 static void dsa_debugfs_regs_read_count(struct dsa_switch *ds, int id,
 					struct seq_file *seq, int count)
 {
@@ -253,6 +267,11 @@ static int dsa_debugfs_create_port(struct dsa_switch *ds, int port)
 	if (err)
 		return err;
 
+	err = dsa_debugfs_create_file(ds, dir, "mdb", port,
+				      &dsa_debugfs_mdb_ops);
+	if (err)
+		return err;
+
 	err = dsa_debugfs_create_file(ds, dir, "regs", port,
 				      &dsa_debugfs_regs_ops);
 	if (err)
-- 
2.14.1
