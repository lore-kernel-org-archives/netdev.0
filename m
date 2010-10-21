From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 02/12] benet: remove dead code
Date: Thu, 21 Oct 2010 10:50:47 -0700
Message-ID: <20101021175148.120535338@vyatta.com>
References: <20101021175045.625707607@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Sathya Perla <sathyap@serverengines.com>,
	Subbu Seetharaman <subbus@serverengines.com>,
	Sarveshwar Bandi <sarveshwarb@serverengines.com>,
	Ajit Kha
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36301 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756330Ab0JUSBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 14:01:05 -0400
Content-Disposition: inline; filename=benet-dead-code.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following code and data are defined but never used in current
driver.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/benet/be_cmds.c	2010-10-21 08:51:17.065487027 -0700
+++ b/drivers/net/benet/be_cmds.c	2010-10-21 08:51:43.768013899 -0700
@@ -1471,42 +1471,6 @@ err:
 	return status;
 }
 
-/* Uses sync mcc */
-int be_cmd_read_port_type(struct be_adapter *adapter, u32 port,
-				u8 *connector)
-{
-	struct be_mcc_wrb *wrb;
-	struct be_cmd_req_port_type *req;
-	int status;
-
-	spin_lock_bh(&adapter->mcc_lock);
-
-	wrb = wrb_from_mccq(adapter);
-	if (!wrb) {
-		status = -EBUSY;
-		goto err;
-	}
-	req = embedded_payload(wrb);
-
-	be_wrb_hdr_prepare(wrb, sizeof(struct be_cmd_resp_port_type), true, 0,
-			OPCODE_COMMON_READ_TRANSRECV_DATA);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_READ_TRANSRECV_DATA, sizeof(*req));
-
-	req->port = cpu_to_le32(port);
-	req->page_num = cpu_to_le32(TR_PAGE_A0);
-	status = be_mcc_notify_wait(adapter);
-	if (!status) {
-		struct be_cmd_resp_port_type *resp = embedded_payload(wrb);
-			*connector = resp->data.connector;
-	}
-
-err:
-	spin_unlock_bh(&adapter->mcc_lock);
-	return status;
-}
-
 int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 			u32 flash_type, u32 flash_opcode, u32 buf_size)
 {
--- a/drivers/net/benet/be_cmds.h	2010-10-21 08:51:17.081488547 -0700
+++ b/drivers/net/benet/be_cmds.h	2010-10-21 08:51:43.768013899 -0700
@@ -1022,8 +1022,6 @@ extern int be_cmd_set_beacon_state(struc
 			u8 port_num, u8 beacon, u8 status, u8 state);
 extern int be_cmd_get_beacon_state(struct be_adapter *adapter,
 			u8 port_num, u32 *state);
-extern int be_cmd_read_port_type(struct be_adapter *adapter, u32 port,
-					u8 *connector);
 extern int be_cmd_write_flashrom(struct be_adapter *adapter,
 			struct be_dma_mem *cmd, u32 flash_oper,
 			u32 flash_opcode, u32 buf_size);
--- a/drivers/net/benet/be_main.c	2010-10-21 08:51:17.105490824 -0700
+++ b/drivers/net/benet/be_main.c	2010-10-21 08:51:43.772014277 -0700
@@ -2299,9 +2299,6 @@ static int be_clear(struct be_adapter *a
 
 
 #define FW_FILE_HDR_SIGN 	"ServerEngines Corp. "
-char flash_cookie[2][16] =	{"*** SE FLAS",
-				"H DIRECTORY *** "};
-
 static bool be_flash_redboot(struct be_adapter *adapter,
 			const u8 *p, u32 img_start, int image_size,
 			int hdr_size)


