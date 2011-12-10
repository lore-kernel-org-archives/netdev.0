From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net: use IS_ENABLED(CONFIG_IPV6)
Date: Sat, 10 Dec 2011 14:00:22 -0800
Message-ID: <1323554422.29470.4.camel@joe2Laptop>
References: <4EE32777.2030003@parallels.com>
	 <4EE327CB.4040505@parallels.com> <1323514931.4016.17.camel@edumazet-laptop>
	 <20111210.131555.2025649575447940902.davem@davemloft.net>
	 <1323546511.4016.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:59968 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750997Ab1LJWAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Dec 2011 17:00:24 -0500
In-Reply-To: <1323546511.4016.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of testing defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)

Signed-off-by: Joe Perches <joe@perches.com>
---

Here's the same for drivers/net/

 drivers/net/ethernet/broadcom/cnic.c   |    2 +-
 drivers/net/wireless/ipw2x00/ipw2100.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 4bcb67e..757b981 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -3516,7 +3516,7 @@ static int cnic_get_v4_route(struct sockaddr_in *dst_addr,
 static int cnic_get_v6_route(struct sockaddr_in6 *dst_addr,
 			     struct dst_entry **dst)
 {
-#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(MODULE))
+#if IS_ENABLED(CONFIG_IPV6)
 	struct flowi6 fl6;
 
 	memset(&fl6, 0, sizeof(fl6));
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index a0e5c21..a469a53 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -4926,7 +4926,7 @@ static int ipw2100_system_config(struct ipw2100_priv *priv, int batch_mode)
 
 /* If IPv6 is configured in the kernel then we don't want to filter out all
  * of the multicast packets as IPv6 needs some. */
-#if !defined(CONFIG_IPV6) && !defined(CONFIG_IPV6_MODULE)
+#if !IS_ENABLED(CONFIG_IPV6)
 	cmd.host_command = ADD_MULTICAST;
 	cmd.host_command_sequence = 0;
 	cmd.host_command_length = 0;
