From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH 16/16] drivers/net/qlcnic: Use available error codes
Date: Mon, 16 Aug 2010 22:23:51 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008162222450.12526@ask.diku.dk>
References: <Pine.LNX.4.64.1008161828520.19313@ask.diku.dk> <20100816183540.GE645@bicker>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:56466 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754842Ab0HPUXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Aug 2010 16:23:54 -0400
In-Reply-To: <20100816183540.GE645@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
This version is based on a more recent version of the file than the 
previous version.

 drivers/net/qlcnic/qlcnic_main.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index bf6d87a..81d9d75 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -474,7 +474,7 @@ static int
 qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_pci_info *pci_info;
-	int i, ret = 0, err;
+	int i, ret = 0;
 	u8 pfn;
 
 	pci_info = kcalloc(QLCNIC_MAX_PCI_FUNC, sizeof(*pci_info), GFP_KERNEL);
@@ -484,14 +484,14 @@ qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 	adapter->npars = kzalloc(sizeof(struct qlcnic_npar_info) *
 				QLCNIC_MAX_PCI_FUNC, GFP_KERNEL);
 	if (!adapter->npars) {
-		err = -ENOMEM;
+		ret = -ENOMEM;
 		goto err_pci_info;
 	}
 
 	adapter->eswitch = kzalloc(sizeof(struct qlcnic_eswitch) *
 				QLCNIC_NIU_MAX_XG_PORTS, GFP_KERNEL);
 	if (!adapter->eswitch) {
-		err = -ENOMEM;
+		ret = -ENOMEM;
 		goto err_npars;
 	}
 
