From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH 1/2] vlan: Calling vlan_hwaccel_do_receive() is
 always valid.
Date: Thu, 21 Oct 2010 17:46:27 -0700
Message-ID: <2DFD360E328B3941911E6D28B085D990129FC20F4E@SJEXCHCCR01.corp.ad.broadcom.com>
References: <1287696643-9695-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "Jesse Gross" <jesse@nicira.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4973 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178Ab0JVAqk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 20:46:40 -0400
In-Reply-To: <1287696643-9695-1-git-send-email-jesse@nicira.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, this solves the problem. 

Tested-by: Dmitry Kravkov <dmitry@broadcom.com>   

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Jesse Gross
Sent: Thursday, October 21, 2010 11:31 PM
To: David Miller
Cc: netdev@vger.kernel.org
Subject: [PATCH 1/2] vlan: Calling vlan_hwaccel_do_receive() is always valid.

It is now acceptable to receive vlan tagged packets at any time,
even if CONFIG_VLAN_8021Q is not set.  This means that calling
vlan_hwaccel_do_receive() should not result in BUG() but rather just
behave as if there were no vlan devices configured.

Reported-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/linux/if_vlan.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index e607256..cbd3dcd 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -153,7 +153,8 @@ static inline u16 vlan_dev_vlan_id(const struct net_device *dev)
 
 static inline bool vlan_hwaccel_do_receive(struct sk_buff **skb)
 {
-	BUG();
+	if ((*skb)->vlan_tci & VLAN_VID_MASK)
+		(*skb)->pkt_type = PACKET_OTHERHOST;
 	return false;
 }
 #endif
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


