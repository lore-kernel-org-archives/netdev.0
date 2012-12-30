From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2 net-next] team: add ethtool support
Date: Sun, 30 Dec 2012 09:51:29 +0100
Message-ID: <20121230085129.GB1575@minipsycho.orion>
References: <1356835053-25602-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:57001 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab2L3Ive (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 03:51:34 -0500
Received: by mail-ee0-f54.google.com with SMTP id c13so5665311eek.27
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 00:51:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1356835053-25602-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Dec 30, 2012 at 03:37:33AM CET, fbl@redhat.com wrote:
>This patch adds few ethtool operations to team driver.
>
>Signed-off-by: Flavio Leitner <fbl@redhat.com>
>---
>v2 - removed generic statistics from ethtool
>
> drivers/net/team/team.c | 17 +++++++++++++++++
> 1 file changed, 17 insertions(+)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index ad86660..7665a088 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -28,6 +28,7 @@
> #include <net/genetlink.h>
> #include <net/netlink.h>
> #include <net/sch_generic.h>
>+#include <generated/utsrelease.h>
> #include <linux/if_team.h>
> 
> #define DRV_NAME "team"
>@@ -1731,6 +1732,21 @@ static const struct net_device_ops team_netdev_ops = {
> 	.ndo_fix_features	= team_fix_features,
> };
> 
>+/***********************
>+ * ethtool interface
>+ ***********************/
>+
>+static void team_ethtool_get_drvinfo(struct net_device *dev,
>+				     struct ethtool_drvinfo *drvinfo)
>+{
>+	strncpy(drvinfo->driver, DRV_NAME, 32);
>+	strncpy(drvinfo->version, UTS_RELEASE, 32);
>+}
>+
>+static const struct ethtool_ops team_ethtool_ops = {
>+	.get_drvinfo		= team_ethtool_get_drvinfo,
>+	.get_link		= ethtool_op_get_link,
>+};
> 
> /***********************
>  * rt netlink interface
>@@ -1780,6 +1796,7 @@ static void team_setup(struct net_device *dev)
> 	ether_setup(dev);
> 
> 	dev->netdev_ops = &team_netdev_ops;
>+	dev->ethtool_ops = &team_ethtool_ops;
> 	dev->destructor	= team_destructor;
> 	dev->tx_queue_len = 0;
> 	dev->flags |= IFF_MULTICAST;
>-- 
>1.8.0.1
>

Acked-by: Jiri Pirko <jiri@resnulli.us>
