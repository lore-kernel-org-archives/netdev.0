From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [patch net-next] ethtool: fix drvinfo strings set in drivers
Date: Sat, 5 Jan 2013 18:23:57 -0200
Message-ID: <20130105202356.GA1967@obelix.rh>
References: <1357415336-17807-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32525 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755872Ab3AEUYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2013 15:24:08 -0500
Content-Disposition: inline
In-Reply-To: <1357415336-17807-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 05, 2013 at 08:48:56PM +0100, Jiri Pirko wrote:
> Use strlcpy where possible to ensure the string is \0 terminated.
> Use always sizeof(string) instead of 32 and custom defines.
> Also use snprintf instead of strcpy in nes_nic.
> Also do not do unnecessary init of drvinfo in spider_net_ethtool.
> 

Looks good. You can add some more fixes to your patch
BTW, I was using ethtool defines, but I think it's cleaner
to use sizeof() instead.

fbl

diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 021d69c..29e272c 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -1448,10 +1448,10 @@ static int e100_set_settings(struct net_device *dev,
 static void e100_get_drvinfo(struct net_device *dev,
 			     struct ethtool_drvinfo *info)
 {
-	strncpy(info->driver, "ETRAX 100LX", sizeof(info->driver) - 1);
-	strncpy(info->version, "$Revision: 1.31 $", sizeof(info->version) - 1);
-	strncpy(info->fw_version, "N/A", sizeof(info->fw_version) - 1);
-	strncpy(info->bus_info, "N/A", sizeof(info->bus_info) - 1);
+	strlcpy(info->driver, "ETRAX 100LX", sizeof(info->driver));
+	strlcpy(info->version, "$Revision: 1.31 $", sizeof(info->version));
+	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
+	strlcpy(info->bus_info, "N/A", sizeof(info->bus_info));
 }
 
 static int e100_nway_reset(struct net_device *dev)
diff --git a/drivers/net/ethernet/3com/3c501.c b/drivers/net/ethernet/3com/3c501.c
index 2038eaa..c6dfbb6 100644
--- a/drivers/net/ethernet/3com/3c501.c
+++ b/drivers/net/ethernet/3com/3c501.c
@@ -823,9 +823,10 @@ static void set_multicast_list(struct net_device *dev)
 static void netdev_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info)
 {
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	sprintf(info->bus_info, "ISA 0x%lx", dev->base_addr);
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	snprintf(info->bus_info, ETHTOOL_BUSINFO_LEN, "ISA 0x%lx",
+		 dev->base_addr);
 }
 
 static u32 netdev_get_msglevel(struct net_device *dev)
diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index 633c709..f36ff99 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -1161,8 +1161,8 @@ el3_netdev_set_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
 
 static void el3_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 }
 
 static int el3_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
diff --git a/drivers/net/ethernet/3com/3c515.c b/drivers/net/ethernet/3com/3c515.c
index 59e1e00..9e9fef3 100644
--- a/drivers/net/ethernet/3com/3c515.c
+++ b/drivers/net/ethernet/3com/3c515.c
@@ -1542,9 +1542,10 @@ static void set_rx_mode(struct net_device *dev)
 static void netdev_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info)
 {
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	sprintf(info->bus_info, "ISA 0x%lx", dev->base_addr);
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	snprintf(info->bus_info, ETHTOOL_BUSINFO_LEN, "ISA 0x%lx",
+		 dev->base_addr);
 }
 
 static u32 netdev_get_msglevel(struct net_device *dev)
