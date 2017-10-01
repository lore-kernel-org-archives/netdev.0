From: =?UTF-8?q?J=C3=A9r=C3=A9my=20Lefaure?=
        <jeremy.lefaure@lse.epita.fr>
Subject: [PATCH 05/18] net: use ARRAY_SIZE
Date: Sun,  1 Oct 2017 15:30:43 -0400
Message-ID: <20171001193101.8898-6-jeremy.lefaure@lse.epita.fr>
References: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?J=C3=A9r=C3=A9my=20Lefaure?=
        <jeremy.lefaure@lse.epita.fr>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, brcm80211-dev-list@cypress.com
To: Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Chi-Hsien Lin <chi-hsien.lin@cypress.com>,
        Wright Feng <wright.feng@cypress.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using the ARRAY_SIZE macro improves the readability of the code. Also,
it is not always useful to use a variable to store this constant
calculated at compile time.

Found with Coccinelle with the following semantic patch:
@r depends on (org || report)@
type T;
T[] E;
position p;
@@
(
 (sizeof(E)@p /sizeof(*E))
|
 (sizeof(E)@p /sizeof(E[...]))
|
 (sizeof(E)@p /sizeof(T))
)

Signed-off-by: Jérémy Lefaure <jeremy.lefaure@lse.epita.fr>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c        |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |   3 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c      |   3 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c            |  17 +-
 drivers/net/usb/kalmia.c                           |   9 +-
 .../broadcom/brcm80211/brcmsmac/phy/phytbl_n.c     | 473 ++++++---------------
 .../net/wireless/realtek/rtlwifi/rtl8723be/hw.c    |   9 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/phy.c   |  12 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/table.c |  14 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/table.c |  34 +-
 include/net/bond_3ad.h                             |   3 +-
 net/ipv6/seg6_local.c                              |   6 +-
 13 files changed, 177 insertions(+), 413 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 02dd5246dfae..ec39363afd5f 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -15,6 +15,7 @@
  * Costa Mesa, CA 92626
  */
 
+#include <linux/kernel.h>
 #include <linux/module.h>
 #include "be.h"
 #include "be_cmds.h"
@@ -103,10 +104,9 @@ static struct be_cmd_priv_map cmd_priv_map[] = {
 static bool be_cmd_allowed(struct be_adapter *adapter, u8 opcode, u8 subsystem)
 {
 	int i;
-	int num_entries = sizeof(cmd_priv_map)/sizeof(struct be_cmd_priv_map);
 	u32 cmd_privileges = adapter->cmd_privileges;
 
-	for (i = 0; i < num_entries; i++)
+	for (i = 0; i < ARRAY_SIZE(cmd_priv_map); i++)
 		if (opcode == cmd_priv_map[i].opcode &&
 		    subsystem == cmd_priv_map[i].subsystem)
 			if (!(cmd_privileges & cmd_priv_map[i].priv_mask))
diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
index 2349fbe04bd2..892083b65b91 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
@@ -27,6 +27,7 @@
 #ifndef _I40E_ADMINQ_H_
 #define _I40E_ADMINQ_H_
 
+#include <linux/kernel.h>
 #include "i40e_osdep.h"
 #include "i40e_status.h"
 #include "i40e_adminq_cmd.h"
@@ -143,7 +144,7 @@ static inline int i40e_aq_rc_to_posix(int aq_ret, int aq_rc)
 	if (aq_ret == I40E_ERR_ADMIN_QUEUE_TIMEOUT)
 		return -EAGAIN;
 
-	if (!((u32)aq_rc < (sizeof(aq_to_posix) / sizeof((aq_to_posix)[0]))))
+	if (!((u32)aq_rc < ARRAY_SIZE(aq_to_posix)))
 		return -ERANGE;
 
 	return aq_to_posix[aq_rc];
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
index e0bfaa3d4a21..5622a24cc74d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
@@ -27,6 +27,7 @@
 #ifndef _I40E_ADMINQ_H_
 #define _I40E_ADMINQ_H_
 
+#include <linux/kernel.h>
 #include "i40e_osdep.h"
 #include "i40e_status.h"
 #include "i40e_adminq_cmd.h"
@@ -143,7 +144,7 @@ static inline int i40e_aq_rc_to_posix(int aq_ret, int aq_rc)
 	if (aq_ret == I40E_ERR_ADMIN_QUEUE_TIMEOUT)
 		return -EAGAIN;
 
-	if (!((u32)aq_rc < (sizeof(aq_to_posix) / sizeof((aq_to_posix)[0]))))
+	if (!((u32)aq_rc < ARRAY_SIZE(aq_to_posix)))
 		return -ERANGE;
 
 	return aq_to_posix[aq_rc];
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 19fbb2f28ea4..9cfc8601fb54 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -21,6 +21,7 @@
  *  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
  *
  ******************************************************************************/
+#include <linux/kernel.h>
 #include "ixgbe_x540.h"
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
@@ -947,7 +948,7 @@ static s32 ixgbe_checksum_ptr_x550(struct ixgbe_hw *hw, u16 ptr,
 	u16 length, bufsz, i, start;
 	u16 *local_buffer;
 
-	bufsz = sizeof(buf) / sizeof(buf[0]);
+	bufsz = ARRAY_SIZE(buf);
 
 	/* Read a chunk at the pointer location */
 	if (!buffer) {
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 0c25006ce9af..96bfef92fb4c 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -24,6 +24,7 @@
 
 *******************************************************************************/
 
+#include <linux/kernel.h>
 #include "vf.h"
 #include "ixgbevf.h"
 
@@ -285,7 +286,7 @@ static s32 ixgbevf_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
 		ether_addr_copy(msg_addr, addr);
 
 	ret_val = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf,
-					     sizeof(msgbuf) / sizeof(u32));
+					     ARRAY_SIZE(msgbuf));
 	if (!ret_val) {
 		msgbuf[0] &= ~IXGBE_VT_MSGTYPE_CTS;
 
@@ -455,7 +456,7 @@ static s32 ixgbevf_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
 	ether_addr_copy(msg_addr, addr);
 
 	ret_val = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf,
-					     sizeof(msgbuf) / sizeof(u32));
+					     ARRAY_SIZE(msgbuf));
 
 	msgbuf[0] &= ~IXGBE_VT_MSGTYPE_CTS;
 
@@ -571,7 +572,7 @@ static s32 ixgbevf_update_xcast_mode(struct ixgbe_hw *hw, int xcast_mode)
 	msgbuf[1] = xcast_mode;
 
 	err = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf,
-					 sizeof(msgbuf) / sizeof(u32));
+					 ARRAY_SIZE(msgbuf));
 	if (err)
 		return err;
 
@@ -609,7 +610,7 @@ static s32 ixgbevf_set_vfta_vf(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 	msgbuf[0] |= vlan_on << IXGBE_VT_MSGINFO_SHIFT;
 
 	err = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf,
-					 sizeof(msgbuf) / sizeof(u32));
+					 ARRAY_SIZE(msgbuf));
 	if (err)
 		goto mbx_err;
 
@@ -813,7 +814,7 @@ static s32 ixgbevf_set_rlpml_vf(struct ixgbe_hw *hw, u16 max_size)
 	msgbuf[1] = max_size;
 
 	ret_val = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf,
-					     sizeof(msgbuf) / sizeof(u32));
+					     ARRAY_SIZE(msgbuf));
 	if (ret_val)
 		return ret_val;
 	if ((msgbuf[0] & IXGBE_VF_SET_LPE) &&
@@ -859,8 +860,7 @@ static int ixgbevf_negotiate_api_version_vf(struct ixgbe_hw *hw, int api)
 	msg[1] = api;
 	msg[2] = 0;
 
-	err = ixgbevf_write_msg_read_ack(hw, msg, msg,
-					 sizeof(msg) / sizeof(u32));
+	err = ixgbevf_write_msg_read_ack(hw, msg, msg, ARRAY_SIZE(msg));
 	if (!err) {
 		msg[0] &= ~IXGBE_VT_MSGTYPE_CTS;
 
@@ -911,8 +911,7 @@ int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 	msg[0] = IXGBE_VF_GET_QUEUE;
 	msg[1] = msg[2] = msg[3] = msg[4] = 0;
 
-	err = ixgbevf_write_msg_read_ack(hw, msg, msg,
-					 sizeof(msg) / sizeof(u32));
+	err = ixgbevf_write_msg_read_ack(hw, msg, msg, ARRAY_SIZE(msg));
 	if (!err) {
 		msg[0] &= ~IXGBE_VT_MSGTYPE_CTS;
 
diff --git a/drivers/net/usb/kalmia.c b/drivers/net/usb/kalmia.c
index ce0b0b4e3a57..6976003d64db 100644
--- a/drivers/net/usb/kalmia.c
+++ b/drivers/net/usb/kalmia.c
@@ -26,6 +26,7 @@
 #include <linux/usb/cdc.h>
 #include <linux/usb/usbnet.h>
 #include <linux/gfp.h>
+#include <linux/kernel.h>
 
 /*
  * The Samsung Kalmia based LTE USB modems have a CDC ACM port for modem control
@@ -114,14 +115,14 @@ kalmia_init_and_get_ethernet_addr(struct usbnet *dev, u8 *ethernet_addr)
 		return -ENOMEM;
 
 	memcpy(usb_buf, init_msg_1, 12);
-	status = kalmia_send_init_packet(dev, usb_buf, sizeof(init_msg_1)
-		/ sizeof(init_msg_1[0]), usb_buf, 24);
+	status = kalmia_send_init_packet(dev, usb_buf, ARRAY_SIZE(init_msg_1),
+					 usb_buf, 24);
 	if (status != 0)
 		return status;
 
 	memcpy(usb_buf, init_msg_2, 12);
-	status = kalmia_send_init_packet(dev, usb_buf, sizeof(init_msg_2)
-		/ sizeof(init_msg_2[0]), usb_buf, 28);
+	status = kalmia_send_init_packet(dev, usb_buf, ARRAY_SIZE(init_msg_2),
+					 usb_buf, 28);
 	if (status != 0)
 		return status;
 
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phytbl_n.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phytbl_n.c
index dbf50ef6cd75..84af04495622 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phytbl_n.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phytbl_n.c
@@ -14,6 +14,7 @@
  * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#include <linux/kernel.h>
 #include <types.h>
 #include "phytbl_n.h"
 
@@ -4437,109 +4438,44 @@ static const u16 loft_lut_core1_rev0[] = {
 };
 
 const struct phytbl_info mimophytbl_info_rev0_volatile[] = {
-	{&bdi_tbl_rev0, sizeof(bdi_tbl_rev0) / sizeof(bdi_tbl_rev0[0]), 21, 0,
-	 16}
-	,
-	{&pltlut_tbl_rev0, sizeof(pltlut_tbl_rev0) / sizeof(pltlut_tbl_rev0[0]),
-	 20, 0, 32}
-	,
-	{&gainctrl_lut_core0_rev0,
-	 sizeof(gainctrl_lut_core0_rev0) / sizeof(gainctrl_lut_core0_rev0[0]),
-	 26, 192, 32}
-	,
-	{&gainctrl_lut_core1_rev0,
-	 sizeof(gainctrl_lut_core1_rev0) / sizeof(gainctrl_lut_core1_rev0[0]),
-	 27, 192, 32}
-	,
-
-	{&est_pwr_lut_core0_rev0,
-	 sizeof(est_pwr_lut_core0_rev0) / sizeof(est_pwr_lut_core0_rev0[0]), 26,
-	 0, 8}
-	,
-	{&est_pwr_lut_core1_rev0,
-	 sizeof(est_pwr_lut_core1_rev0) / sizeof(est_pwr_lut_core1_rev0[0]), 27,
-	 0, 8}
-	,
-	{&adj_pwr_lut_core0_rev0,
-	 sizeof(adj_pwr_lut_core0_rev0) / sizeof(adj_pwr_lut_core0_rev0[0]), 26,
-	 64, 8}
-	,
-	{&adj_pwr_lut_core1_rev0,
-	 sizeof(adj_pwr_lut_core1_rev0) / sizeof(adj_pwr_lut_core1_rev0[0]), 27,
-	 64, 8}
-	,
-	{&iq_lut_core0_rev0,
-	 sizeof(iq_lut_core0_rev0) / sizeof(iq_lut_core0_rev0[0]), 26, 320, 32}
-	,
-	{&iq_lut_core1_rev0,
-	 sizeof(iq_lut_core1_rev0) / sizeof(iq_lut_core1_rev0[0]), 27, 320, 32}
-	,
-	{&loft_lut_core0_rev0,
-	 sizeof(loft_lut_core0_rev0) / sizeof(loft_lut_core0_rev0[0]), 26, 448,
-	 16}
-	,
-	{&loft_lut_core1_rev0,
-	 sizeof(loft_lut_core1_rev0) / sizeof(loft_lut_core1_rev0[0]), 27, 448,
-	 16}
-	,
+	{&bdi_tbl_rev0, ARRAY_SIZE(bdi_tbl_rev0), 21, 0, 16},
+	{&pltlut_tbl_rev0, ARRAY_SIZE(pltlut_tbl_rev0), 20, 0, 32},
+	{&gainctrl_lut_core0_rev0, ARRAY_SIZE(gainctrl_lut_core0_rev0), 26, 192,
+	 32},
+	{&gainctrl_lut_core1_rev0, ARRAY_SIZE(gainctrl_lut_core1_rev0), 27, 192,
+	 32},
+	{&est_pwr_lut_core0_rev0, ARRAY_SIZE(est_pwr_lut_core0_rev0), 26, 0, 8},
+	{&est_pwr_lut_core1_rev0, ARRAY_SIZE(est_pwr_lut_core1_rev0), 27, 0, 8},
+	{&adj_pwr_lut_core0_rev0, ARRAY_SIZE(adj_pwr_lut_core0_rev0), 26, 64,
+	 8},
+	{&adj_pwr_lut_core1_rev0, ARRAY_SIZE(adj_pwr_lut_core1_rev0), 27, 64,
+	 8},
+	{&iq_lut_core0_rev0, ARRAY_SIZE(iq_lut_core0_rev0), 26, 320, 32},
+	{&iq_lut_core1_rev0, ARRAY_SIZE(iq_lut_core1_rev0), 27, 320, 32},
+	{&loft_lut_core0_rev0, ARRAY_SIZE(loft_lut_core0_rev0), 26, 448, 16},
+	{&loft_lut_core1_rev0, ARRAY_SIZE(loft_lut_core1_rev0), 27, 448, 16},
 };
 
 const struct phytbl_info mimophytbl_info_rev0[] = {
-	{&frame_struct_rev0,
-	 sizeof(frame_struct_rev0) / sizeof(frame_struct_rev0[0]), 10, 0, 32}
-	,
-	{&frame_lut_rev0, sizeof(frame_lut_rev0) / sizeof(frame_lut_rev0[0]),
-	 24, 0, 8}
-	,
-	{&tmap_tbl_rev0, sizeof(tmap_tbl_rev0) / sizeof(tmap_tbl_rev0[0]), 12,
-	 0, 32}
-	,
-	{&tdtrn_tbl_rev0, sizeof(tdtrn_tbl_rev0) / sizeof(tdtrn_tbl_rev0[0]),
-	 14, 0, 32}
-	,
-	{&intlv_tbl_rev0, sizeof(intlv_tbl_rev0) / sizeof(intlv_tbl_rev0[0]),
-	 13, 0, 32}
-	,
-	{&pilot_tbl_rev0, sizeof(pilot_tbl_rev0) / sizeof(pilot_tbl_rev0[0]),
-	 11, 0, 16}
-	,
-	{&tdi_tbl20_ant0_rev0,
-	 sizeof(tdi_tbl20_ant0_rev0) / sizeof(tdi_tbl20_ant0_rev0[0]), 19, 128,
-	 32}
-	,
-	{&tdi_tbl20_ant1_rev0,
-	 sizeof(tdi_tbl20_ant1_rev0) / sizeof(tdi_tbl20_ant1_rev0[0]), 19, 256,
-	 32}
-	,
-	{&tdi_tbl40_ant0_rev0,
-	 sizeof(tdi_tbl40_ant0_rev0) / sizeof(tdi_tbl40_ant0_rev0[0]), 19, 640,
-	 32}
-	,
-	{&tdi_tbl40_ant1_rev0,
-	 sizeof(tdi_tbl40_ant1_rev0) / sizeof(tdi_tbl40_ant1_rev0[0]), 19, 768,
-	 32}
-	,
-	{&chanest_tbl_rev0,
-	 sizeof(chanest_tbl_rev0) / sizeof(chanest_tbl_rev0[0]), 22, 0, 32}
-	,
-	{&mcs_tbl_rev0, sizeof(mcs_tbl_rev0) / sizeof(mcs_tbl_rev0[0]), 18, 0,
-	 8}
-	,
-	{&noise_var_tbl0_rev0,
-	 sizeof(noise_var_tbl0_rev0) / sizeof(noise_var_tbl0_rev0[0]), 16, 0,
-	 32}
-	,
-	{&noise_var_tbl1_rev0,
-	 sizeof(noise_var_tbl1_rev0) / sizeof(noise_var_tbl1_rev0[0]), 16, 128,
-	 32}
-	,
+	{&frame_struct_rev0, ARRAY_SIZE(frame_struct_rev0), 10, 0, 32},
+	{&frame_lut_rev0, ARRAY_SIZE(frame_lut_rev0), 24, 0, 8},
+	{&tmap_tbl_rev0, ARRAY_SIZE(tmap_tbl_rev0), 12, 0, 32},
+	{&tdtrn_tbl_rev0, ARRAY_SIZE(tdtrn_tbl_rev0), 14, 0, 32},
+	{&intlv_tbl_rev0, ARRAY_SIZE(intlv_tbl_rev0), 13, 0, 32},
+	{&pilot_tbl_rev0, ARRAY_SIZE(pilot_tbl_rev0), 11, 0, 16},
+	{&tdi_tbl20_ant0_rev0, ARRAY_SIZE(tdi_tbl20_ant0_rev0), 19, 128, 32},
+	{&tdi_tbl20_ant1_rev0, ARRAY_SIZE(tdi_tbl20_ant1_rev0), 19, 256, 32},
+	{&tdi_tbl40_ant0_rev0, ARRAY_SIZE(tdi_tbl40_ant0_rev0), 19, 640, 32},
+	{&tdi_tbl40_ant1_rev0, ARRAY_SIZE(tdi_tbl40_ant1_rev0), 19, 768, 32},
+	{&chanest_tbl_rev0, ARRAY_SIZE(chanest_tbl_rev0), 22, 0, 32},
+	{&mcs_tbl_rev0, ARRAY_SIZE(mcs_tbl_rev0), 18, 0, 8},
+	{&noise_var_tbl0_rev0, ARRAY_SIZE(noise_var_tbl0_rev0), 16, 0, 32},
+	{&noise_var_tbl1_rev0, ARRAY_SIZE(noise_var_tbl1_rev0), 16, 128, 32},
 };
 
-const u32 mimophytbl_info_sz_rev0 =
-	sizeof(mimophytbl_info_rev0) / sizeof(mimophytbl_info_rev0[0]);
+const u32 mimophytbl_info_sz_rev0 = ARRAY_SIZE(mimophytbl_info_rev0);
 const u32 mimophytbl_info_sz_rev0_volatile =
-	sizeof(mimophytbl_info_rev0_volatile) /
-	sizeof(mimophytbl_info_rev0_volatile[0]);
+	ARRAY_SIZE(mimophytbl_info_rev0_volatile);
 
 static const u16 ant_swctrl_tbl_rev3[] = {
 	0x0082,
@@ -9363,132 +9299,61 @@ static const u32 papd_cal_scalars_tbl_core1_rev3[] = {
 };
 
 const struct phytbl_info mimophytbl_info_rev3_volatile[] = {
-	{&ant_swctrl_tbl_rev3,
-	 sizeof(ant_swctrl_tbl_rev3) / sizeof(ant_swctrl_tbl_rev3[0]), 9, 0, 16}
-	,
+	{&ant_swctrl_tbl_rev3, ARRAY_SIZE(ant_swctrl_tbl_rev3), 9, 0, 16},
 };
 
 const struct phytbl_info mimophytbl_info_rev3_volatile1[] = {
-	{&ant_swctrl_tbl_rev3_1,
-	 sizeof(ant_swctrl_tbl_rev3_1) / sizeof(ant_swctrl_tbl_rev3_1[0]), 9, 0,
-	 16}
-	,
+	{&ant_swctrl_tbl_rev3_1, ARRAY_SIZE(ant_swctrl_tbl_rev3_1), 9, 0, 16},
 };
 
 const struct phytbl_info mimophytbl_info_rev3_volatile2[] = {
-	{&ant_swctrl_tbl_rev3_2,
-	 sizeof(ant_swctrl_tbl_rev3_2) / sizeof(ant_swctrl_tbl_rev3_2[0]), 9, 0,
-	 16}
-	,
+	{&ant_swctrl_tbl_rev3_2, ARRAY_SIZE(ant_swctrl_tbl_rev3_2), 9, 0, 16},
 };
 
 const struct phytbl_info mimophytbl_info_rev3_volatile3[] = {
-	{&ant_swctrl_tbl_rev3_3,
-	 sizeof(ant_swctrl_tbl_rev3_3) / sizeof(ant_swctrl_tbl_rev3_3[0]), 9, 0,
-	 16}
-	,
+	{&ant_swctrl_tbl_rev3_3, ARRAY_SIZE(ant_swctrl_tbl_rev3_3), 9, 0, 16},
 };
 
 const struct phytbl_info mimophytbl_info_rev3[] = {
-	{&frame_struct_rev3,
-	 sizeof(frame_struct_rev3) / sizeof(frame_struct_rev3[0]), 10, 0, 32}
-	,
-	{&pilot_tbl_rev3, sizeof(pilot_tbl_rev3) / sizeof(pilot_tbl_rev3[0]),
-	 11, 0, 16}
-	,
-	{&tmap_tbl_rev3, sizeof(tmap_tbl_rev3) / sizeof(tmap_tbl_rev3[0]), 12,
-	 0, 32}
-	,
-	{&intlv_tbl_rev3, sizeof(intlv_tbl_rev3) / sizeof(intlv_tbl_rev3[0]),
-	 13, 0, 32}
-	,
-	{&tdtrn_tbl_rev3, sizeof(tdtrn_tbl_rev3) / sizeof(tdtrn_tbl_rev3[0]),
-	 14, 0, 32}
-	,
-	{&noise_var_tbl_rev3,
-	 sizeof(noise_var_tbl_rev3) / sizeof(noise_var_tbl_rev3[0]), 16, 0, 32}
-	,
-	{&mcs_tbl_rev3, sizeof(mcs_tbl_rev3) / sizeof(mcs_tbl_rev3[0]), 18, 0,
-	 16}
-	,
-	{&tdi_tbl20_ant0_rev3,
-	 sizeof(tdi_tbl20_ant0_rev3) / sizeof(tdi_tbl20_ant0_rev3[0]), 19, 128,
-	 32}
-	,
-	{&tdi_tbl20_ant1_rev3,
-	 sizeof(tdi_tbl20_ant1_rev3) / sizeof(tdi_tbl20_ant1_rev3[0]), 19, 256,
-	 32}
-	,
-	{&tdi_tbl40_ant0_rev3,
-	 sizeof(tdi_tbl40_ant0_rev3) / sizeof(tdi_tbl40_ant0_rev3[0]), 19, 640,
-	 32}
-	,
-	{&tdi_tbl40_ant1_rev3,
-	 sizeof(tdi_tbl40_ant1_rev3) / sizeof(tdi_tbl40_ant1_rev3[0]), 19, 768,
-	 32}
-	,
-	{&pltlut_tbl_rev3, sizeof(pltlut_tbl_rev3) / sizeof(pltlut_tbl_rev3[0]),
-	 20, 0, 32}
-	,
-	{&chanest_tbl_rev3,
-	 sizeof(chanest_tbl_rev3) / sizeof(chanest_tbl_rev3[0]), 22, 0, 32}
-	,
-	{&frame_lut_rev3, sizeof(frame_lut_rev3) / sizeof(frame_lut_rev3[0]),
-	 24, 0, 8}
-	,
-	{&est_pwr_lut_core0_rev3,
-	 sizeof(est_pwr_lut_core0_rev3) / sizeof(est_pwr_lut_core0_rev3[0]), 26,
-	 0, 8}
-	,
-	{&est_pwr_lut_core1_rev3,
-	 sizeof(est_pwr_lut_core1_rev3) / sizeof(est_pwr_lut_core1_rev3[0]), 27,
-	 0, 8}
-	,
-	{&adj_pwr_lut_core0_rev3,
-	 sizeof(adj_pwr_lut_core0_rev3) / sizeof(adj_pwr_lut_core0_rev3[0]), 26,
-	 64, 8}
-	,
-	{&adj_pwr_lut_core1_rev3,
-	 sizeof(adj_pwr_lut_core1_rev3) / sizeof(adj_pwr_lut_core1_rev3[0]), 27,
-	 64, 8}
-	,
-	{&gainctrl_lut_core0_rev3,
-	 sizeof(gainctrl_lut_core0_rev3) / sizeof(gainctrl_lut_core0_rev3[0]),
-	 26, 192, 32}
-	,
-	{&gainctrl_lut_core1_rev3,
-	 sizeof(gainctrl_lut_core1_rev3) / sizeof(gainctrl_lut_core1_rev3[0]),
-	 27, 192, 32}
-	,
-	{&iq_lut_core0_rev3,
-	 sizeof(iq_lut_core0_rev3) / sizeof(iq_lut_core0_rev3[0]), 26, 320, 32}
-	,
-	{&iq_lut_core1_rev3,
-	 sizeof(iq_lut_core1_rev3) / sizeof(iq_lut_core1_rev3[0]), 27, 320, 32}
-	,
-	{&loft_lut_core0_rev3,
-	 sizeof(loft_lut_core0_rev3) / sizeof(loft_lut_core0_rev3[0]), 26, 448,
-	 16}
-	,
-	{&loft_lut_core1_rev3,
-	 sizeof(loft_lut_core1_rev3) / sizeof(loft_lut_core1_rev3[0]), 27, 448,
-	 16}
+	{&frame_struct_rev3, ARRAY_SIZE(frame_struct_rev3), 10, 0, 32},
+	{&pilot_tbl_rev3, ARRAY_SIZE(pilot_tbl_rev3), 11, 0, 16},
+	{&tmap_tbl_rev3, ARRAY_SIZE(tmap_tbl_rev3), 12, 0, 32},
+	{&intlv_tbl_rev3, ARRAY_SIZE(intlv_tbl_rev3), 13, 0, 32},
+	{&tdtrn_tbl_rev3, ARRAY_SIZE(tdtrn_tbl_rev3), 14, 0, 32},
+	{&noise_var_tbl_rev3, ARRAY_SIZE(noise_var_tbl_rev3), 16, 0, 32},
+	{&mcs_tbl_rev3, ARRAY_SIZE(mcs_tbl_rev3), 18, 0, 16},
+	{&tdi_tbl20_ant0_rev3, ARRAY_SIZE(tdi_tbl20_ant0_rev3), 19, 128, 32},
+	{&tdi_tbl20_ant1_rev3, ARRAY_SIZE(tdi_tbl20_ant1_rev3), 19, 256, 32},
+	{&tdi_tbl40_ant0_rev3, ARRAY_SIZE(tdi_tbl40_ant0_rev3), 19, 640, 32},
+	{&tdi_tbl40_ant1_rev3, ARRAY_SIZE(tdi_tbl40_ant1_rev3), 19, 768, 32},
+	{&pltlut_tbl_rev3, ARRAY_SIZE(pltlut_tbl_rev3), 20, 0, 32},
+	{&chanest_tbl_rev3, ARRAY_SIZE(chanest_tbl_rev3), 22, 0, 32},
+	{&frame_lut_rev3, ARRAY_SIZE(frame_lut_rev3), 24, 0, 8},
+	{&est_pwr_lut_core0_rev3, ARRAY_SIZE(est_pwr_lut_core0_rev3), 26, 0, 8},
+	{&est_pwr_lut_core1_rev3, ARRAY_SIZE(est_pwr_lut_core1_rev3), 27, 0, 8},
+	{&adj_pwr_lut_core0_rev3, ARRAY_SIZE(adj_pwr_lut_core0_rev3), 26, 64,
+	 8},
+	{&adj_pwr_lut_core1_rev3, ARRAY_SIZE(adj_pwr_lut_core1_rev3), 27, 64,
+	 8},
+	{&gainctrl_lut_core0_rev3, ARRAY_SIZE(gainctrl_lut_core0_rev3), 26, 192,
+	 32},
+	{&gainctrl_lut_core1_rev3, ARRAY_SIZE(gainctrl_lut_core1_rev3), 27, 192,
+	 32},
+	{&iq_lut_core0_rev3, ARRAY_SIZE(iq_lut_core0_rev3), 26, 320, 32},
+	{&iq_lut_core1_rev3, ARRAY_SIZE(iq_lut_core1_rev3), 27, 320, 32},
+	{&loft_lut_core0_rev3, ARRAY_SIZE(loft_lut_core0_rev3), 26, 448, 16},
+	{&loft_lut_core1_rev3, ARRAY_SIZE(loft_lut_core1_rev3), 27, 448, 16}
 };
 
-const u32 mimophytbl_info_sz_rev3 =
-	sizeof(mimophytbl_info_rev3) / sizeof(mimophytbl_info_rev3[0]);
+const u32 mimophytbl_info_sz_rev3 = ARRAY_SIZE(mimophytbl_info_rev3);
 const u32 mimophytbl_info_sz_rev3_volatile =
-	sizeof(mimophytbl_info_rev3_volatile) /
-	sizeof(mimophytbl_info_rev3_volatile[0]);
+	ARRAY_SIZE(mimophytbl_info_rev3_volatile);
 const u32 mimophytbl_info_sz_rev3_volatile1 =
-	sizeof(mimophytbl_info_rev3_volatile1) /
-	sizeof(mimophytbl_info_rev3_volatile1[0]);
+	ARRAY_SIZE(mimophytbl_info_rev3_volatile1);
 const u32 mimophytbl_info_sz_rev3_volatile2 =
-	sizeof(mimophytbl_info_rev3_volatile2) /
-	sizeof(mimophytbl_info_rev3_volatile2[0]);
+	ARRAY_SIZE(mimophytbl_info_rev3_volatile2);
 const u32 mimophytbl_info_sz_rev3_volatile3 =
-	sizeof(mimophytbl_info_rev3_volatile3) /
-	sizeof(mimophytbl_info_rev3_volatile3[0]);
+	ARRAY_SIZE(mimophytbl_info_rev3_volatile3);
 
 static const u32 tmap_tbl_rev7[] = {
 	0x8a88aa80,
@@ -10469,162 +10334,66 @@ static const u32 papd_cal_scalars_tbl_core1_rev7[] = {
 };
 
 const struct phytbl_info mimophytbl_info_rev7[] = {
-	{&frame_struct_rev3,
-	 sizeof(frame_struct_rev3) / sizeof(frame_struct_rev3[0]), 10, 0, 32}
-	,
-	{&pilot_tbl_rev3, sizeof(pilot_tbl_rev3) / sizeof(pilot_tbl_rev3[0]),
-	 11, 0, 16}
-	,
-	{&tmap_tbl_rev7, sizeof(tmap_tbl_rev7) / sizeof(tmap_tbl_rev7[0]), 12,
-	 0, 32}
-	,
-	{&intlv_tbl_rev3, sizeof(intlv_tbl_rev3) / sizeof(intlv_tbl_rev3[0]),
-	 13, 0, 32}
-	,
-	{&tdtrn_tbl_rev3, sizeof(tdtrn_tbl_rev3) / sizeof(tdtrn_tbl_rev3[0]),
-	 14, 0, 32}
-	,
-	{&noise_var_tbl_rev7,
-	 sizeof(noise_var_tbl_rev7) / sizeof(noise_var_tbl_rev7[0]), 16, 0, 32}
-	,
-	{&mcs_tbl_rev3, sizeof(mcs_tbl_rev3) / sizeof(mcs_tbl_rev3[0]), 18, 0,
-	 16}
-	,
-	{&tdi_tbl20_ant0_rev3,
-	 sizeof(tdi_tbl20_ant0_rev3) / sizeof(tdi_tbl20_ant0_rev3[0]), 19, 128,
-	 32}
-	,
-	{&tdi_tbl20_ant1_rev3,
-	 sizeof(tdi_tbl20_ant1_rev3) / sizeof(tdi_tbl20_ant1_rev3[0]), 19, 256,
-	 32}
-	,
-	{&tdi_tbl40_ant0_rev3,
-	 sizeof(tdi_tbl40_ant0_rev3) / sizeof(tdi_tbl40_ant0_rev3[0]), 19, 640,
-	 32}
-	,
-	{&tdi_tbl40_ant1_rev3,
-	 sizeof(tdi_tbl40_ant1_rev3) / sizeof(tdi_tbl40_ant1_rev3[0]), 19, 768,
-	 32}
-	,
-	{&pltlut_tbl_rev3, sizeof(pltlut_tbl_rev3) / sizeof(pltlut_tbl_rev3[0]),
-	 20, 0, 32}
-	,
-	{&chanest_tbl_rev3,
-	 sizeof(chanest_tbl_rev3) / sizeof(chanest_tbl_rev3[0]), 22, 0, 32}
-	,
-	{&frame_lut_rev3, sizeof(frame_lut_rev3) / sizeof(frame_lut_rev3[0]),
-	 24, 0, 8}
-	,
-	{&est_pwr_lut_core0_rev3,
-	 sizeof(est_pwr_lut_core0_rev3) / sizeof(est_pwr_lut_core0_rev3[0]), 26,
-	 0, 8}
-	,
-	{&est_pwr_lut_core1_rev3,
-	 sizeof(est_pwr_lut_core1_rev3) / sizeof(est_pwr_lut_core1_rev3[0]), 27,
-	 0, 8}
-	,
-	{&adj_pwr_lut_core0_rev3,
-	 sizeof(adj_pwr_lut_core0_rev3) / sizeof(adj_pwr_lut_core0_rev3[0]), 26,
-	 64, 8}
-	,
-	{&adj_pwr_lut_core1_rev3,
-	 sizeof(adj_pwr_lut_core1_rev3) / sizeof(adj_pwr_lut_core1_rev3[0]), 27,
-	 64, 8}
-	,
-	{&gainctrl_lut_core0_rev3,
-	 sizeof(gainctrl_lut_core0_rev3) / sizeof(gainctrl_lut_core0_rev3[0]),
-	 26, 192, 32}
-	,
-	{&gainctrl_lut_core1_rev3,
-	 sizeof(gainctrl_lut_core1_rev3) / sizeof(gainctrl_lut_core1_rev3[0]),
-	 27, 192, 32}
-	,
-	{&iq_lut_core0_rev3,
-	 sizeof(iq_lut_core0_rev3) / sizeof(iq_lut_core0_rev3[0]), 26, 320, 32}
-	,
-	{&iq_lut_core1_rev3,
-	 sizeof(iq_lut_core1_rev3) / sizeof(iq_lut_core1_rev3[0]), 27, 320, 32}
-	,
-	{&loft_lut_core0_rev3,
-	 sizeof(loft_lut_core0_rev3) / sizeof(loft_lut_core0_rev3[0]), 26, 448,
-	 16}
-	,
-	{&loft_lut_core1_rev3,
-	 sizeof(loft_lut_core1_rev3) / sizeof(loft_lut_core1_rev3[0]), 27, 448,
-	 16}
-	,
+	{&frame_struct_rev3, ARRAY_SIZE(frame_struct_rev3), 10, 0, 32},
+	{&pilot_tbl_rev3, ARRAY_SIZE(pilot_tbl_rev3), 11, 0, 16},
+	{&tmap_tbl_rev7, ARRAY_SIZE(tmap_tbl_rev7), 12, 0, 32},
+	{&intlv_tbl_rev3, ARRAY_SIZE(intlv_tbl_rev3), 13, 0, 32},
+	{&tdtrn_tbl_rev3, ARRAY_SIZE(tdtrn_tbl_rev3), 14, 0, 32},
+	{&noise_var_tbl_rev7, ARRAY_SIZE(noise_var_tbl_rev7), 16, 0, 32},
+	{&mcs_tbl_rev3, ARRAY_SIZE(mcs_tbl_rev3), 18, 0, 16},
+	{&tdi_tbl20_ant0_rev3, ARRAY_SIZE(tdi_tbl20_ant0_rev3), 19, 128, 32},
+	{&tdi_tbl20_ant1_rev3, ARRAY_SIZE(tdi_tbl20_ant1_rev3), 19, 256, 32},
+	{&tdi_tbl40_ant0_rev3, ARRAY_SIZE(tdi_tbl40_ant0_rev3), 19, 640, 32},
+	{&tdi_tbl40_ant1_rev3, ARRAY_SIZE(tdi_tbl40_ant1_rev3), 19, 768, 32},
+	{&pltlut_tbl_rev3, ARRAY_SIZE(pltlut_tbl_rev3), 20, 0, 32},
+	{&chanest_tbl_rev3, ARRAY_SIZE(chanest_tbl_rev3), 22, 0, 32},
+	{&frame_lut_rev3, ARRAY_SIZE(frame_lut_rev3), 24, 0, 8},
+	{&est_pwr_lut_core0_rev3, ARRAY_SIZE(est_pwr_lut_core0_rev3), 26, 0, 8},
+	{&est_pwr_lut_core1_rev3, ARRAY_SIZE(est_pwr_lut_core1_rev3), 27, 0, 8},
+	{&adj_pwr_lut_core0_rev3, ARRAY_SIZE(adj_pwr_lut_core0_rev3), 26, 64,
+	 8},
+	{&adj_pwr_lut_core1_rev3, ARRAY_SIZE(adj_pwr_lut_core1_rev3), 27, 64,
+	 8},
+	{&gainctrl_lut_core0_rev3, ARRAY_SIZE(gainctrl_lut_core0_rev3), 26, 192,
+	 32},
+	{&gainctrl_lut_core1_rev3, ARRAY_SIZE(gainctrl_lut_core1_rev3), 27, 192,
+	 32},
+	{&iq_lut_core0_rev3, ARRAY_SIZE(iq_lut_core0_rev3), 26, 320, 32},
+	{&iq_lut_core1_rev3, ARRAY_SIZE(iq_lut_core1_rev3), 27, 320, 32},
+	{&loft_lut_core0_rev3, ARRAY_SIZE(loft_lut_core0_rev3), 26, 448, 16},
+	{&loft_lut_core1_rev3, ARRAY_SIZE(loft_lut_core1_rev3), 27, 448, 16},
 	{&papd_comp_rfpwr_tbl_core0_rev3,
-	 sizeof(papd_comp_rfpwr_tbl_core0_rev3) /
-	 sizeof(papd_comp_rfpwr_tbl_core0_rev3[0]), 26, 576, 16}
-	,
+	 ARRAY_SIZE(papd_comp_rfpwr_tbl_core0_rev3), 26, 576, 16},
 	{&papd_comp_rfpwr_tbl_core1_rev3,
-	 sizeof(papd_comp_rfpwr_tbl_core1_rev3) /
-	 sizeof(papd_comp_rfpwr_tbl_core1_rev3[0]), 27, 576, 16}
-	,
+	 ARRAY_SIZE(papd_comp_rfpwr_tbl_core1_rev3), 27, 576, 16},
 	{&papd_comp_epsilon_tbl_core0_rev7,
-	 sizeof(papd_comp_epsilon_tbl_core0_rev7) /
-	 sizeof(papd_comp_epsilon_tbl_core0_rev7[0]), 31, 0, 32}
-	,
+	 ARRAY_SIZE(papd_comp_epsilon_tbl_core0_rev7), 31, 0, 32},
 	{&papd_cal_scalars_tbl_core0_rev7,
-	 sizeof(papd_cal_scalars_tbl_core0_rev7) /
-	 sizeof(papd_cal_scalars_tbl_core0_rev7[0]), 32, 0, 32}
-	,
+	 ARRAY_SIZE(papd_cal_scalars_tbl_core0_rev7), 32, 0, 32},
 	{&papd_comp_epsilon_tbl_core1_rev7,
-	 sizeof(papd_comp_epsilon_tbl_core1_rev7) /
-	 sizeof(papd_comp_epsilon_tbl_core1_rev7[0]), 33, 0, 32}
-	,
+	 ARRAY_SIZE(papd_comp_epsilon_tbl_core1_rev7), 33, 0, 32},
 	{&papd_cal_scalars_tbl_core1_rev7,
-	 sizeof(papd_cal_scalars_tbl_core1_rev7) /
-	 sizeof(papd_cal_scalars_tbl_core1_rev7[0]), 34, 0, 32}
-	,
+	 ARRAY_SIZE(papd_cal_scalars_tbl_core1_rev7), 34, 0, 32},
 };
 
-const u32 mimophytbl_info_sz_rev7 =
-	sizeof(mimophytbl_info_rev7) / sizeof(mimophytbl_info_rev7[0]);
+const u32 mimophytbl_info_sz_rev7 = ARRAY_SIZE(mimophytbl_info_rev7);
 
 const struct phytbl_info mimophytbl_info_rev16[] = {
-	{&noise_var_tbl_rev7,
-	 sizeof(noise_var_tbl_rev7) / sizeof(noise_var_tbl_rev7[0]), 16, 0, 32}
-	,
-	{&est_pwr_lut_core0_rev3,
-	 sizeof(est_pwr_lut_core0_rev3) / sizeof(est_pwr_lut_core0_rev3[0]), 26,
-	 0, 8}
-	,
-	{&est_pwr_lut_core1_rev3,
-	 sizeof(est_pwr_lut_core1_rev3) / sizeof(est_pwr_lut_core1_rev3[0]), 27,
-	 0, 8}
-	,
-	{&adj_pwr_lut_core0_rev3,
-	 sizeof(adj_pwr_lut_core0_rev3) / sizeof(adj_pwr_lut_core0_rev3[0]), 26,
-	 64, 8}
-	,
-	{&adj_pwr_lut_core1_rev3,
-	 sizeof(adj_pwr_lut_core1_rev3) / sizeof(adj_pwr_lut_core1_rev3[0]), 27,
-	 64, 8}
-	,
-	{&gainctrl_lut_core0_rev3,
-	 sizeof(gainctrl_lut_core0_rev3) / sizeof(gainctrl_lut_core0_rev3[0]),
-	 26, 192, 32}
-	,
-	{&gainctrl_lut_core1_rev3,
-	 sizeof(gainctrl_lut_core1_rev3) / sizeof(gainctrl_lut_core1_rev3[0]),
-	 27, 192, 32}
-	,
-	{&iq_lut_core0_rev3,
-	 sizeof(iq_lut_core0_rev3) / sizeof(iq_lut_core0_rev3[0]), 26, 320, 32}
-	,
-	{&iq_lut_core1_rev3,
-	 sizeof(iq_lut_core1_rev3) / sizeof(iq_lut_core1_rev3[0]), 27, 320, 32}
-	,
-	{&loft_lut_core0_rev3,
-	 sizeof(loft_lut_core0_rev3) / sizeof(loft_lut_core0_rev3[0]), 26, 448,
-	 16}
-	,
-	{&loft_lut_core1_rev3,
-	 sizeof(loft_lut_core1_rev3) / sizeof(loft_lut_core1_rev3[0]), 27, 448,
-	 16}
-	,
+	{&noise_var_tbl_rev7, ARRAY_SIZE(noise_var_tbl_rev7), 16, 0, 32},
+	{&est_pwr_lut_core0_rev3, ARRAY_SIZE(est_pwr_lut_core0_rev3), 26, 0, 8},
+	{&est_pwr_lut_core1_rev3, ARRAY_SIZE(est_pwr_lut_core1_rev3), 27, 0, 8},
+	{&adj_pwr_lut_core0_rev3, ARRAY_SIZE(adj_pwr_lut_core0_rev3), 26, 64,
+	 8},
+	{&adj_pwr_lut_core1_rev3, ARRAY_SIZE(adj_pwr_lut_core1_rev3), 27, 64,
+	 8},
+	{&gainctrl_lut_core0_rev3, ARRAY_SIZE(gainctrl_lut_core0_rev3), 26, 192,
+	 32},
+	{&gainctrl_lut_core1_rev3, ARRAY_SIZE(gainctrl_lut_core1_rev3), 27, 192,
+	 32},
+	{&iq_lut_core0_rev3, ARRAY_SIZE(iq_lut_core0_rev3), 26, 320, 32},
+	{&iq_lut_core1_rev3, ARRAY_SIZE(iq_lut_core1_rev3), 27, 320, 32},
+	{&loft_lut_core0_rev3, ARRAY_SIZE(loft_lut_core0_rev3), 26, 448, 16},
+	{&loft_lut_core1_rev3, ARRAY_SIZE(loft_lut_core1_rev3), 27, 448, 16},
 };
 
-const u32 mimophytbl_info_sz_rev16 =
-	sizeof(mimophytbl_info_rev16) / sizeof(mimophytbl_info_rev16[0]);
+const u32 mimophytbl_info_sz_rev16 = ARRAY_SIZE(mimophytbl_info_rev16);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
index 4d47b97adfed..fb035ea13553 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
@@ -43,6 +43,7 @@
 #include "../pwrseqcmd.h"
 #include "pwrseq.h"
 #include "../btcoexist/rtl_btc.h"
+#include <linux/kernel.h>
 
 #define LLT_CONFIG	5
 
@@ -2125,28 +2126,28 @@ static void _rtl8723be_read_adapter_info(struct ieee80211_hw *hw,
 
 	if (rtlhal->oem_id == RT_CID_DEFAULT) {
 		/* Does this one have a Toshiba SMID from group 1? */
-		for (i = 0; i < sizeof(toshiba_smid1) / sizeof(u16); i++) {
+		for (i = 0; i < ARRAY_SIZE(toshiba_smid1); i++) {
 			if (rtlefuse->eeprom_smid == toshiba_smid1[i]) {
 				is_toshiba_smid1 = true;
 				break;
 			}
 		}
 		/* Does this one have a Toshiba SMID from group 2? */
-		for (i = 0; i < sizeof(toshiba_smid2) / sizeof(u16); i++) {
+		for (i = 0; i < ARRAY_SIZE(toshiba_smid2); i++) {
 			if (rtlefuse->eeprom_smid == toshiba_smid2[i]) {
 				is_toshiba_smid2 = true;
 				break;
 			}
 		}
 		/* Does this one have a Samsung SMID? */
-		for (i = 0; i < sizeof(samsung_smid) / sizeof(u16); i++) {
+		for (i = 0; i < ARRAY_SIZE(samsung_smid); i++) {
 			if (rtlefuse->eeprom_smid == samsung_smid[i]) {
 				is_samsung_smid = true;
 				break;
 			}
 		}
 		/* Does this one have a Lenovo SMID? */
-		for (i = 0; i < sizeof(lenovo_smid) / sizeof(u16); i++) {
+		for (i = 0; i < ARRAY_SIZE(lenovo_smid); i++) {
 			if (rtlefuse->eeprom_smid == lenovo_smid[i]) {
 				is_lenovo_smid = true;
 				break;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c
index 9606641519e7..1263b12db5dc 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c
@@ -35,6 +35,7 @@
 #include "../rtl8723com/dm_common.h"
 #include "table.h"
 #include "trx.h"
+#include <linux/kernel.h>
 
 static bool _rtl8723be_phy_bb8723b_config_parafile(struct ieee80211_hw *hw);
 static bool _rtl8723be_phy_config_mac_with_headerfile(struct ieee80211_hw *hw);
@@ -1143,14 +1144,13 @@ void rtl8723be_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel)
 			     DESC92C_RATEMCS2, DESC92C_RATEMCS3,
 			     DESC92C_RATEMCS4, DESC92C_RATEMCS5,
 			     DESC92C_RATEMCS6, DESC92C_RATEMCS7};
-	u8 i, size;
+	u8 i;
 	u8 power_index;
 
 	if (!rtlefuse->txpwr_fromeprom)
 		return;
 
-	size = sizeof(cck_rates) / sizeof(u8);
-	for (i = 0; i < size; i++) {
+	for (i = 0; i < ARRAY_SIZE(cck_rates); i++) {
 		power_index = _rtl8723be_get_txpower_index(hw, RF90_PATH_A,
 					cck_rates[i],
 					rtl_priv(hw)->phy.current_chan_bw,
@@ -1158,8 +1158,7 @@ void rtl8723be_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel)
 		_rtl8723be_phy_set_txpower_index(hw, power_index, RF90_PATH_A,
 						 cck_rates[i]);
 	}
-	size = sizeof(ofdm_rates) / sizeof(u8);
-	for (i = 0; i < size; i++) {
+	for (i = 0; i < ARRAY_SIZE(ofdm_rates); i++) {
 		power_index = _rtl8723be_get_txpower_index(hw, RF90_PATH_A,
 					ofdm_rates[i],
 					rtl_priv(hw)->phy.current_chan_bw,
@@ -1167,8 +1166,7 @@ void rtl8723be_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel)
 		_rtl8723be_phy_set_txpower_index(hw, power_index, RF90_PATH_A,
 						 ofdm_rates[i]);
 	}
-	size = sizeof(ht_rates_1t) / sizeof(u8);
-	for (i = 0; i < size; i++) {
+	for (i = 0; i < ARRAY_SIZE(ht_rates_1t); i++) {
 		power_index = _rtl8723be_get_txpower_index(hw, RF90_PATH_A,
 					ht_rates_1t[i],
 					rtl_priv(hw)->phy.current_chan_bw,
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/table.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/table.c
index 381c16b9b3a9..160fee8333ae 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/table.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/table.c
@@ -25,6 +25,7 @@
  *
  *****************************************************************************/
 
+#include <linux/kernel.h>
 #include "table.h"
 
 u32 RTL8723BEPHY_REG_1TARRAY[] = {
@@ -224,8 +225,7 @@ u32 RTL8723BEPHY_REG_1TARRAY[] = {
 
 };
 
-u32 RTL8723BEPHY_REG_1TARRAYLEN =
-	sizeof(RTL8723BEPHY_REG_1TARRAY) / sizeof(u32);
+u32 RTL8723BEPHY_REG_1TARRAYLEN = ARRAY_SIZE(RTL8723BEPHY_REG_1TARRAY);
 
 u32 RTL8723BEPHY_REG_ARRAY_PG[] = {
 	0, 0, 0, 0x00000e08, 0x0000ff00, 0x00003800,
@@ -236,8 +236,7 @@ u32 RTL8723BEPHY_REG_ARRAY_PG[] = {
 	0, 0, 0, 0x00000e14, 0xffffffff, 0x26303436
 };
 
-u32 RTL8723BEPHY_REG_ARRAY_PGLEN =
-		sizeof(RTL8723BEPHY_REG_ARRAY_PG) / sizeof(u32);
+u32 RTL8723BEPHY_REG_ARRAY_PGLEN = ARRAY_SIZE(RTL8723BEPHY_REG_ARRAY_PG);
 
 u32 RTL8723BE_RADIOA_1TARRAY[] = {
 		0x000, 0x00010000,
@@ -373,8 +372,7 @@ u32 RTL8723BE_RADIOA_1TARRAY[] = {
 
 };
 
-u32 RTL8723BE_RADIOA_1TARRAYLEN =
-	sizeof(RTL8723BE_RADIOA_1TARRAY) / sizeof(u32);
+u32 RTL8723BE_RADIOA_1TARRAYLEN = ARRAY_SIZE(RTL8723BE_RADIOA_1TARRAY);
 
 u32 RTL8723BEMAC_1T_ARRAY[] = {
 		0x02F, 0x00000030,
@@ -483,7 +481,7 @@ u32 RTL8723BEMAC_1T_ARRAY[] = {
 
 };
 
-u32 RTL8723BEMAC_1T_ARRAYLEN = sizeof(RTL8723BEMAC_1T_ARRAY) / sizeof(u32);
+u32 RTL8723BEMAC_1T_ARRAYLEN = ARRAY_SIZE(RTL8723BEMAC_1T_ARRAY);
 
 u32 RTL8723BEAGCTAB_1TARRAY[] = {
 		0xC78, 0xFD000001,
@@ -620,4 +618,4 @@ u32 RTL8723BEAGCTAB_1TARRAY[] = {
 
 };
 
-u32 RTL8723BEAGCTAB_1TARRAYLEN = sizeof(RTL8723BEAGCTAB_1TARRAY) / sizeof(u32);
+u32 RTL8723BEAGCTAB_1TARRAYLEN = ARRAY_SIZE(RTL8723BEAGCTAB_1TARRAY);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/table.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/table.c
index 408c4611e5de..f87f9d03b9fa 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/table.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/table.c
@@ -24,7 +24,7 @@
  * Larry Finger <Larry.Finger@lwfinger.net>
  *
  *****************************************************************************/
-
+#include <linux/kernel.h>
 #include "table.h"
 u32 RTL8812AE_PHY_REG_ARRAY[] = {
 		0x800, 0x8020D010,
@@ -258,8 +258,7 @@ u32 RTL8812AE_PHY_REG_ARRAY[] = {
 		0xEB8, 0x00508242,
 };
 
-u32 RTL8812AE_PHY_REG_1TARRAYLEN =
-	sizeof(RTL8812AE_PHY_REG_ARRAY) / sizeof(u32);
+u32 RTL8812AE_PHY_REG_1TARRAYLEN = ARRAY_SIZE(RTL8812AE_PHY_REG_ARRAY);
 
 u32 RTL8821AE_PHY_REG_ARRAY[] = {
 	0x800, 0x0020D090,
@@ -436,8 +435,7 @@ u32 RTL8821AE_PHY_REG_ARRAY[] = {
 	0xCB8, 0x00508240,
 };
 
-u32 RTL8821AE_PHY_REG_1TARRAYLEN =
-	sizeof(RTL8821AE_PHY_REG_ARRAY) / sizeof(u32);
+u32 RTL8821AE_PHY_REG_1TARRAYLEN = ARRAY_SIZE(RTL8821AE_PHY_REG_ARRAY);
 
 u32 RTL8812AE_PHY_REG_ARRAY_PG[] = {
 	0, 0, 0, 0x00000c20, 0xffffffff, 0x34363840,
@@ -488,8 +486,7 @@ u32 RTL8812AE_PHY_REG_ARRAY_PG[] = {
 	1, 1, 1, 0x00000e4c, 0xffffffff, 0x22242628
 };
 
-u32 RTL8812AE_PHY_REG_ARRAY_PGLEN =
-		sizeof(RTL8812AE_PHY_REG_ARRAY_PG) / sizeof(u32);
+u32 RTL8812AE_PHY_REG_ARRAY_PGLEN = ARRAY_SIZE(RTL8812AE_PHY_REG_ARRAY_PG);
 
 u32 RTL8821AE_PHY_REG_ARRAY_PG[] = {
 	0, 0, 0, 0x00000c20, 0xffffffff, 0x32343638,
@@ -509,8 +506,7 @@ u32 RTL8821AE_PHY_REG_ARRAY_PG[] = {
 	1, 0, 0, 0x00000c44, 0x0000ffff, 0x00002022
 };
 
-u32 RTL8821AE_PHY_REG_ARRAY_PGLEN =
-		sizeof(RTL8821AE_PHY_REG_ARRAY_PG) / sizeof(u32);
+u32 RTL8821AE_PHY_REG_ARRAY_PGLEN = ARRAY_SIZE(RTL8821AE_PHY_REG_ARRAY_PG);
 
 u32 RTL8812AE_RADIOA_ARRAY[] = {
 		0x000, 0x00010000,
@@ -927,7 +923,7 @@ u32 RTL8812AE_RADIOA_ARRAY[] = {
 		0x018, 0x0001712A,
 };
 
-u32 RTL8812AE_RADIOA_1TARRAYLEN = sizeof(RTL8812AE_RADIOA_ARRAY) / sizeof(u32);
+u32 RTL8812AE_RADIOA_1TARRAYLEN = ARRAY_SIZE(RTL8812AE_RADIOA_ARRAY);
 
 u32 RTL8812AE_RADIOB_ARRAY[] = {
 		0x056, 0x00051CF2,
@@ -1335,7 +1331,7 @@ u32 RTL8812AE_RADIOB_ARRAY[] = {
 		0x008, 0x00008400,
 };
 
-u32 RTL8812AE_RADIOB_1TARRAYLEN = sizeof(RTL8812AE_RADIOB_ARRAY) / sizeof(u32);
+u32 RTL8812AE_RADIOB_1TARRAYLEN = ARRAY_SIZE(RTL8812AE_RADIOB_ARRAY);
 
 u32 RTL8821AE_RADIOA_ARRAY[] = {
 		0x018, 0x0001712A,
@@ -1929,7 +1925,7 @@ u32 RTL8821AE_RADIOA_ARRAY[] = {
 
 };
 
-u32 RTL8821AE_RADIOA_1TARRAYLEN = sizeof(RTL8821AE_RADIOA_ARRAY) / sizeof(u32);
+u32 RTL8821AE_RADIOA_1TARRAYLEN = ARRAY_SIZE(RTL8821AE_RADIOA_ARRAY);
 
 u32 RTL8812AE_MAC_REG_ARRAY[] = {
 		0x010, 0x0000000C,
@@ -2041,7 +2037,7 @@ u32 RTL8812AE_MAC_REG_ARRAY[] = {
 		0x718, 0x00000040,
 };
 
-u32 RTL8812AE_MAC_1T_ARRAYLEN = sizeof(RTL8812AE_MAC_REG_ARRAY) / sizeof(u32);
+u32 RTL8812AE_MAC_1T_ARRAYLEN = ARRAY_SIZE(RTL8812AE_MAC_REG_ARRAY);
 
 u32 RTL8821AE_MAC_REG_ARRAY[] = {
 		0x428, 0x0000000A,
@@ -2143,7 +2139,7 @@ u32 RTL8821AE_MAC_REG_ARRAY[] = {
 		0x718, 0x00000040,
 };
 
-u32 RTL8821AE_MAC_1T_ARRAYLEN = sizeof(RTL8821AE_MAC_REG_ARRAY) / sizeof(u32);
+u32 RTL8821AE_MAC_1T_ARRAYLEN = ARRAY_SIZE(RTL8821AE_MAC_REG_ARRAY);
 
 u32 RTL8812AE_AGC_TAB_ARRAY[] = {
 	0x80000001, 0x00000000, 0x40000000, 0x00000000,
@@ -2479,8 +2475,7 @@ u32 RTL8812AE_AGC_TAB_ARRAY[] = {
 		0xE50, 0x00000020,
 };
 
-u32 RTL8812AE_AGC_TAB_1TARRAYLEN =
-	sizeof(RTL8812AE_AGC_TAB_ARRAY) / sizeof(u32);
+u32 RTL8812AE_AGC_TAB_1TARRAYLEN = ARRAY_SIZE(RTL8812AE_AGC_TAB_ARRAY);
 
 u32 RTL8821AE_AGC_TAB_ARRAY[] = {
 		0x81C, 0xBF000001,
@@ -2676,8 +2671,7 @@ u32 RTL8821AE_AGC_TAB_ARRAY[] = {
 		0xC50, 0x00000020,
 };
 
-u32 RTL8821AE_AGC_TAB_1TARRAYLEN =
-	sizeof(RTL8821AE_AGC_TAB_ARRAY) / sizeof(u32);
+u32 RTL8821AE_AGC_TAB_1TARRAYLEN = ARRAY_SIZE(RTL8821AE_AGC_TAB_ARRAY);
 
 /******************************************************************************
 *                           TXPWR_LMT.TXT
@@ -3250,7 +3244,7 @@ u8 *RTL8812AE_TXPWR_LMT[] = {
 	"MKK", "5G", "80M", "VHT", "2T", "155", "63"
 };
 
-u32 RTL8812AE_TXPWR_LMT_ARRAY_LEN = sizeof(RTL8812AE_TXPWR_LMT) / sizeof(u8 *);
+u32 RTL8812AE_TXPWR_LMT_ARRAY_LEN = ARRAY_SIZE(RTL8812AE_TXPWR_LMT);
 
 u8 *RTL8821AE_TXPWR_LMT[] = {
 	"FCC", "2.4G", "20M", "CCK", "1T", "01", "32",
@@ -3819,4 +3813,4 @@ u8 *RTL8821AE_TXPWR_LMT[] = {
 	"MKK", "5G", "80M", "VHT", "2T", "155", "63"
 };
 
-u32 RTL8821AE_TXPWR_LMT_ARRAY_LEN = sizeof(RTL8821AE_TXPWR_LMT) / sizeof(u8 *);
+u32 RTL8821AE_TXPWR_LMT_ARRAY_LEN = ARRAY_SIZE(RTL8821AE_TXPWR_LMT);
diff --git a/include/net/bond_3ad.h b/include/net/bond_3ad.h
index f358ad5e4214..7a06fa295814 100644
--- a/include/net/bond_3ad.h
+++ b/include/net/bond_3ad.h
@@ -27,6 +27,7 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/if_ether.h>
+#include <linux/kernel.h>
 
 /* General definitions */
 #define PKT_TYPE_LACPDU         cpu_to_be16(ETH_P_SLOW)
@@ -283,7 +284,7 @@ static inline const char *bond_3ad_churn_desc(churn_state_t state)
 		"none",
 		"unknown"
 	};
-	int max_size = sizeof(churn_description) / sizeof(churn_description[0]);
+	int max_size = ARRAY_SIZE(churn_description);
 
 	if (state >= max_size)
 		state = max_size - 1;
diff --git a/net/ipv6/seg6_local.c b/net/ipv6/seg6_local.c
index 825b8e01f947..9e4e1dc89e29 100644
--- a/net/ipv6/seg6_local.c
+++ b/net/ipv6/seg6_local.c
@@ -31,6 +31,7 @@
 #include <net/seg6_hmac.h>
 #endif
 #include <linux/etherdevice.h>
+#include <linux/kernel.h>
 
 struct seg6_local_lwt;
 
@@ -499,10 +500,9 @@ static struct seg6_action_desc seg6_action_table[] = {
 static struct seg6_action_desc *__get_action_desc(int action)
 {
 	struct seg6_action_desc *desc;
-	int i, count;
+	int i;
 
-	count = sizeof(seg6_action_table) / sizeof(struct seg6_action_desc);
-	for (i = 0; i < count; i++) {
+	for (i = 0; i < ARRAY_SIZE(seg6_action_table); i++) {
 		desc = &seg6_action_table[i];
 		if (desc->action == action)
 			return desc;
-- 
2.14.1
