From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC WIP 5/5] net: dsa: Don't include CPU port when
	adding MDB to a port
Date: Sat, 26 Aug 2017 22:56:10 +0200
Message-ID: <1503780970-10312-6-git-send-email-andrew@lunn.ch>
References: <1503780970-10312-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	nikolay@cumulusnetworks.com, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, jiri@mellanox.com
To: netdev <netdev@vger.kernel.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1503780970-10312-1-git-send-email-andrew@lunn.ch>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Now that the MDB are explicitly added to the CPU port when required,
don't add the CPU port adding an MDB to a switch port.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/switch.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index 97e2e9c8cf3f..c178e2b86a9a 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -130,7 +130,7 @@ static int dsa_switch_mdb_add(struct dsa_switch *ds,
 	if (ds->index == info->sw_index)
 		set_bit(info->port, group);
 	for (port = 0; port < ds->num_ports; port++)
-		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
+		if (dsa_is_dsa_port(ds, port))
 			set_bit(port, group);
 
 	if (switchdev_trans_ph_prepare(trans)) {
-- 
2.14.1
