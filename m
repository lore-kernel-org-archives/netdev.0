From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mlxsw: fix warnings for big-endian 32-bit dma_addr_t
Date: Tue, 06 Oct 2015 23:47:44 +0200
Message-ID: <30258520.VaA2vDyUiY@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, Jiri Pirko <jiri@mellanox.com>,
	Ido Schimmel <idosch@mellanox.com>,
	linux-kernel@vger.kernel.org, Elad Raz <eladr@mellanox.com>,
	Scott Feldman <sfeldma@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The recently added mlxsw driver produces warnings in ARM
allmodconfig:

drivers/net/ethernet/mellanox/mlxsw/pci.c: In function 'mlxsw_pci_cmd_exec':
drivers/net/ethernet/mellanox/mlxsw/pci.c:1585:59: warning: right shift count >= width of type [-Wshift-count-overflow]
linux/byteorder/big_endian.h:38:51: note: in definition of macro '__cpu_to_be32'
drivers/net/ethernet/mellanox/mlxsw/pci.c:76:2: note: in expansion of macro 'iowrite32be'

This changes the type of the local variable to u64, which gets rid of the
warning and seems nicer than adding #ifdefs.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: eda6500a987a "mlxsw: Add PCI bus implementation"

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 462cea31ecbb..cd11e3591741 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1567,8 +1567,8 @@ static int mlxsw_pci_cmd_exec(void *bus_priv, u16 opcode, u8 opcode_mod,
 			      u8 *p_status)
 {
 	struct mlxsw_pci *mlxsw_pci = bus_priv;
-	dma_addr_t in_mapaddr = mlxsw_pci->cmd.in_mbox.mapaddr;
-	dma_addr_t out_mapaddr = mlxsw_pci->cmd.out_mbox.mapaddr;
+	u64 in_mapaddr = mlxsw_pci->cmd.in_mbox.mapaddr;
+	u64 out_mapaddr = mlxsw_pci->cmd.out_mbox.mapaddr;
 	bool evreq = mlxsw_pci->cmd.nopoll;
 	unsigned long timeout = msecs_to_jiffies(MLXSW_PCI_CIR_TIMEOUT_MSECS);
 	bool *p_wait_done = &mlxsw_pci->cmd.wait_done;
