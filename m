From: Colin King <colin.king@canonical.com>
Subject: [PATCH] cxgb4vf: make a couple of functions static
Date: Wed,  4 Oct 2017 14:20:37 +0100
Message-ID: <20171004132037.6409-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Casey Leedom <leedom@chelsio.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The functions t4vf_link_down_rc_str and t4vf_handle_get_port_info are
local to the source and do not need to be in global scope, so make
them static.

Cleans up sparse warnings:
symbol 't4vf_link_down_rc_str' was not declared. Should it be static?
symbol 't4vf_handle_get_port_info' was not declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index a8d94963b4d0..67aec59a14e6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -1812,7 +1812,7 @@ int t4vf_eth_eq_free(struct adapter *adapter, unsigned int eqid)
  *
  *	Returns a string representation of the Link Down Reason Code.
  */
-const char *t4vf_link_down_rc_str(unsigned char link_down_rc)
+static const char *t4vf_link_down_rc_str(unsigned char link_down_rc)
 {
 	static const char * const reason[] = {
 		"Link Down",
@@ -1838,8 +1838,8 @@ const char *t4vf_link_down_rc_str(unsigned char link_down_rc)
  *
  *	Processes a GET_PORT_INFO FW reply message.
  */
-void t4vf_handle_get_port_info(struct port_info *pi,
-			       const struct fw_port_cmd *cmd)
+static void t4vf_handle_get_port_info(struct port_info *pi,
+				      const struct fw_port_cmd *cmd)
 {
 	int action = FW_PORT_CMD_ACTION_G(be32_to_cpu(cmd->action_to_len16));
 	struct adapter *adapter = pi->adapter;
-- 
2.14.1
