From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] qlcnic: remove unnecessary static in qlcnic_dump_fw()
Date: Tue, 18 Jul 2017 15:45:29 -0500
Message-ID: <20170718204529.GA11448@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: Harish Patil <harish.patil@cavium.com>,
        Manish Chopra <manish.chopra@cavium.com>,
        Dept-GELinuxNICDev@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unnecessary static on local variable fw_dump_ops.
Such variable is initialized before being used, on every
execution path throughout the function. The static has no
benefit and, removing it reduces the object file size.

This issue was detected using Coccinelle and the following semantic patch:

@bad exists@
position p;
identifier x;
type T;
@@

static T x@p;
...
x = <+...x...+>

@@
identifier x;
expression e;
type T;
position p != bad.p;
@@

-static
 T x@p;
 ... when != x
     when strict
?x = e;

In the following log you can see a difference in the object file size.
This log is the output of the size command, before and after the code
change:

before:
   text    data     bss     dec     hex filename
  19032    2136      64   21232    52f0 drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.o

after:
   text    data     bss     dec     hex filename
  19020    2048       0   21068    524c drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.o

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index 0844b7c..afa10a1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -1285,7 +1285,7 @@ int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter)
 int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
-	static const struct qlcnic_dump_operations *fw_dump_ops;
+	const struct qlcnic_dump_operations *fw_dump_ops;
 	struct qlcnic_83xx_dump_template_hdr *hdr_83xx;
 	u32 entry_offset, dump, no_entries, buf_offset = 0;
 	int i, k, ops_cnt, ops_index, dump_size = 0;
-- 
2.5.0
