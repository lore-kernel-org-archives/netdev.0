From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 09/11] net: dsa: debugfs: add port mdb
Date: Mon, 14 Aug 2017 18:22:40 -0400
Message-ID: <20170814222242.10643-10-vivien.didelot@savoirfairelinux.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a debug filesystem "mdb" entry to query a port's hardware MDB
entries through the .port_mdb_dump switch operation.

This is really convenient to query directly the hardware or inspect DSA
or CPU links, since these ports are not exposed to userspace.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/debugfs.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
index 8204c62dc9c1..98c5068d20da 100644
--- a/net/dsa/debugfs.c
+++ b/net/dsa/debugfs.c
@@ -140,6 +140,20 @@ static const struct dsa_debugfs_ops dsa_debugfs_fdb_ops = {
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
@@ -289,6 +303,11 @@ static int dsa_debugfs_create_port(struct dsa_switch *ds, int port)
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
2.14.0
