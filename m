From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [04/10] pasemi_mac: Fix memcpy amount for short receives
Date: Wed, 22 Aug 2007 09:12:55 -0500
Message-ID: <20070822141255.GE16830@lixom.net>
References: <20070817205413.548020000@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline; filename=pasemi_mac-bugfix
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Fix up memcpy for short receives.

Signed-off-by: Olof Johansson <olof@lixom.net>


Index: mainline/drivers/net/pasemi_mac.c
===================================================================
--- mainline.orig/drivers/net/pasemi_mac.c
+++ mainline/drivers/net/pasemi_mac.c
@@ -516,9 +516,7 @@ static int pasemi_mac_clean_rx(struct pa
 			    netdev_alloc_skb(mac->netdev, len + NET_IP_ALIGN);
 			if (new_skb) {
 				skb_reserve(new_skb, NET_IP_ALIGN);
-				memcpy(new_skb->data - NET_IP_ALIGN,
-					skb->data - NET_IP_ALIGN,
-					len + NET_IP_ALIGN);
+				memcpy(new_skb->data, skb->data, len);
 				/* save the skb in buffer_info as good */
 				skb = new_skb;
 			}

--
