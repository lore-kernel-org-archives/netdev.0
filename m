From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 16/16] drivers/net/qlcnic: Use available error codes
Date: Mon, 16 Aug 2010 18:29:13 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008161828520.19313@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kern
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

The error code is stored in the variable err, but it is the variable ret
that is returned instead.  So store the error code in ret.  Err is then
useless.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r@
local idexpression x;
constant C;
@@

if (...) { ...
  x = -C
  ... when != x
(
  return <+...x...+>;
|
  return NULL;
|
  return;
|
* return ...;
)
}
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
This changes the semantics and has not been tested.

 drivers/net/qlcnic/qlcnic_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index b9615bd..142ab1d 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -474,7 +474,7 @@ static int
 qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_pci_info pci_info[QLCNIC_MAX_PCI_FUNC];
-	int i, ret = 0, err;
+	int i, ret = 0;
 	u8 pfn;
 
 	if (!adapter->npars)
@@ -487,7 +487,7 @@ qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 		adapter->eswitch = kzalloc(sizeof(struct qlcnic_eswitch) *
 				QLCNIC_NIU_MAX_XG_PORTS, GFP_KERNEL);
 	if (!adapter->eswitch) {
-		err = -ENOMEM;
+		ret = -ENOMEM;
 		goto err_eswitch;
 	}
 
