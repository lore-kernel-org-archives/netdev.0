From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 05/11] mlxsw: fix error return code
Date: Sun, 23 Aug 2015 02:11:16 +0200
Message-ID: <1440288682-12732-6-git-send-email-Julia.Lawall@lip6.fr>
References: <1440288682-12732-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Ido Schimmel <idosch@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440288682-12732-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return a negative error code on failure.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
identifier ret; expression e1,e2;
@@
(
if (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/mellanox/mlxsw/pci.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index a34f474..045f98f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1726,6 +1726,7 @@ static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 						mlxsw_pci_dbg_root);
 	if (!mlxsw_pci->dbg_dir) {
 		dev_err(&pdev->dev, "Failed to create debugfs dir\n");
+		err = -ENOMEM;
 		goto err_dbg_create_dir;
 	}
 
