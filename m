From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 4/7] devlink: Adding perm config of link settings
Date: Wed, 18 Oct 2017 09:31:51 +0200
Message-ID: <20171018073151.GC2028@nanopsycho>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-5-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, davem@davemloft.net,
        michael.chan@broadcom.com, linville@tuxdriver.com,
        gospo@broadcom.com
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:43613 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762429AbdJRHbx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 03:31:53 -0400
Received: by mail-wm0-f65.google.com with SMTP id m72so11587409wmc.0
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 00:31:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1508273069-40461-5-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 17, 2017 at 10:44:26PM CEST, steven.lin1@broadcom.com wrote:
>Extending DEVLINK_ATTR_PERM_CFG (permanent/NVRAM device configuration)
>to include persistent configuration of device link settings:
>
>DEVLINK_ATTR_PERM_CFG_AUTONEG_PROTOCOL: Configure default autoneg
>protocol; use enum devlink_autoneg_protocol.
>
>DEVLINK_ATTR_PERM_CFG_MEDIA_AUTO_DETECT: Configure default
>auto-detection of attached media connector (1 = enable, 0 =
>disable).
>
>DEVLINK_ATTR_PERM_CFG_PHY_SELECT: Configure default external PHY
>selection (0 = PHY 0, 1 = PHY 1).
>
>DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D0: Configure default
>pre-OS link speed in full power (D0) state; use enum
>devlink_pre_os_link_speed.
>
>DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D3: Configure default
>pre-OS link speed in sleep (D3) state; use enum
>devlink_pre_os_link_speed.
>
>Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>Acked-by: Andy Gospodarek <gospo@broadcom.com>
>---
> include/uapi/linux/devlink.h | 27 ++++++++++++++++++++++++++-
> net/core/devlink.c           |  5 +++++
> 2 files changed, 31 insertions(+), 1 deletion(-)
>
>diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
>index 4a9eafd..2e1c006 100644
>--- a/include/uapi/linux/devlink.h
>+++ b/include/uapi/linux/devlink.h
>@@ -142,6 +142,26 @@ enum devlink_multifunc_mode {
> 	DEVLINK_MULTIFUNC_MODE_NPAR20,		/* NPAR 2.0 */
> };
> 
>+enum devlink_autoneg_protocol {
>+	DEVLINK_AUTONEG_PROTOCOL_IEEE8023BY_BAM,
>+	DEVLINK_AUTONEG_PROTOCOL_IEEE8023BY_CONSORTIUM,
>+	DEVLINK_AUTONEG_PROTOCOL_IEEE8023BY,
>+	DEVLINK_AUTONEG_PROTOCOL_BAM,		/* Broadcom Autoneg Mode */
>+	DEVLINK_AUTONEG_PROTOCOL_CONSORTIUM,	/* Consortium Autoneg Mode */
>+};
>+
>+enum devlink_pre_os_link_speed {
>+	DEVLINK_PRE_OS_LINK_SPEED_AUTONEG,
>+	DEVLINK_PRE_OS_LINK_SPEED_1G,
>+	DEVLINK_PRE_OS_LINK_SPEED_10G,
>+	DEVLINK_PRE_OS_LINK_SPEED_25G,
>+	DEVLINK_PRE_OS_LINK_SPEED_40G,
>+	DEVLINK_PRE_OS_LINK_SPEED_50G,
>+	DEVLINK_PRE_OS_LINK_SPEED_100G,
>+	DEVLINK_PRE_OS_LINK_SPEED_5G = 0xe,
>+	DEVLINK_PRE_OS_LINK_SPEED_100M = 0xf,
>+};
>+
> enum devlink_attr {
> 	/* don't change the order or add anything between, this is ABI! */
> 	DEVLINK_ATTR_UNSPEC,
>@@ -249,9 +269,14 @@ enum devlink_attr {
> 	DEVLINK_ATTR_PERM_CFG_PME_CAPABILITY_ENABLED,	/* u8 */
> 	DEVLINK_ATTR_PERM_CFG_MAGIC_PACKET_WOL_ENABLED,	/* u8 */
> 	DEVLINK_ATTR_PERM_CFG_EEE_PWR_SAVE_ENABLED,	/* u8 */
>+	DEVLINK_ATTR_PERM_CFG_AUTONEG_PROTOCOL,		/* u32 */
>+	DEVLINK_ATTR_PERM_CFG_MEDIA_AUTO_DETECT,	/* u8 */
>+	DEVLINK_ATTR_PERM_CFG_PHY_SELECT,		/* u8 */
>+	DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D0,	/* u32 */
>+	DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D3,	/* u32 */


You need to split the config option to those that are per-port and to
those that are per-asic. For each family, you have to use ither
devlink_port of devlink handle. Also, you need to split into those that are
permanent and to those who are teporary (until reset). I think you might
need some flags for that.
