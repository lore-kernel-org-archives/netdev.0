From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 6/7] cpsw: add a DT field for the cpts offset
Date: Mon, 15 Oct 2012 21:48:12 +0200
Message-ID: <16b8977cddffb24436144d8053c1376653ccf109.1350329726.git.richardcochran@gmail.com>
References: <cover.1350329726.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Sriramakrishnan A G <srk@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:48587 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893Ab2JOTtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 15:49:20 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so4753829wgb.1
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 12:49:19 -0700 (PDT)
In-Reply-To: <cover.1350329726.git.richardcochran@gmail.com>
In-Reply-To: <cover.1350329726.git.richardcochran@gmail.com>
References: <cover.1350329726.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |    3 +++
 arch/arm/boot/dts/am33xx.dtsi                  |    1 +
 drivers/net/ethernet/ti/cpsw.c                 |    7 +++++++
 include/linux/platform_data/cpsw.h             |    1 +
 4 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 3af47b7..dba014f 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -16,6 +16,7 @@ Required properties:
 - ale_entries		: Specifies No of entries ALE can hold
 - host_port_reg_ofs	: Specifies host port register offset
 - hw_stats_reg_ofs	: Specifies hardware statistics register offset
+- cpts_reg_ofs		: Specifies the offset of the CPTS registers
 - bd_ram_ofs		: Specifies internal desciptor RAM offset
 - bd_ram_size		: Specifies internal descriptor RAM size
 - rx_descs		: Specifies number of Rx descriptors
@@ -52,6 +53,7 @@ Examples:
 		ale_entries = <1024>;
 		host_port_reg_ofs = <0x108>;
 		hw_stats_reg_ofs = <0x900>;
+		cpts_reg_ofs = <0xc00>;
 		bd_ram_ofs = <0x2000>;
 		bd_ram_size = <0x2000>;
 		no_bd_ram = <0>;
@@ -86,6 +88,7 @@ Examples:
 		ale_entries = <1024>;
 		host_port_reg_ofs = <0x108>;
 		hw_stats_reg_ofs = <0x900>;
+		cpts_reg_ofs = <0xc00>;
 		bd_ram_ofs = <0x2000>;
 		bd_ram_size = <0x2000>;
 		no_bd_ram = <0>;
diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index cd9b3b4..c981753 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -222,6 +222,7 @@
 			ale_entries = <1024>;
 			host_port_reg_ofs = <0x108>;
 			hw_stats_reg_ofs = <0x900>;
+			cpts_reg_ofs = <0xc00>;
 			bd_ram_ofs = <0x2000>;
 			bd_ram_size = <0x2000>;
 			no_bd_ram = <0>;
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e29bb8f..aeaa3bb 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -817,6 +817,13 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->hw_stats_reg_ofs = prop;
 
+	if (of_property_read_u32(node, "cpts_reg_ofs", &prop)) {
+		pr_err("Missing cpts_reg_ofs property in the DT.\n");
+		ret = -EINVAL;
+		goto error_ret;
+	}
+	data->cpts_reg_ofs = prop;
+
 	if (of_property_read_u32(node, "bd_ram_ofs", &prop)) {
 		pr_err("Missing bd_ram_ofs property in the DT.\n");
 		ret = -EINVAL;
diff --git a/include/linux/platform_data/cpsw.h b/include/linux/platform_data/cpsw.h
index c4e23d0..a052b1d 100644
--- a/include/linux/platform_data/cpsw.h
+++ b/include/linux/platform_data/cpsw.h
@@ -41,6 +41,7 @@ struct cpsw_platform_data {
 	u32     host_port_num; /* The port number for the host port */
 
 	u32	hw_stats_reg_ofs;  /* cpsw hardware statistics counters */
+	u32	cpts_reg_ofs;      /* cpts registers */
 
 	u32	bd_ram_ofs;   /* embedded buffer descriptor RAM offset*/
 	u32	bd_ram_size;  /*buffer descriptor ram size */
-- 
1.7.2.5
