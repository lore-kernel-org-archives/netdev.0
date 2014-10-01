From: Andy Zhou <azhou@nicira.com>
Subject: [datapath minor fixes 2/3] datapath: avoid double free routing entry in vxlan_port xmit
Date: Wed,  1 Oct 2014 00:55:47 -0700
Message-ID: <1412150148-9991-3-git-send-email-azhou@nicira.com>
References: <1412150148-9991-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:58554 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751520AbaJAHy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 03:54:57 -0400
Received: by mail-pd0-f178.google.com with SMTP id y10so317682pdj.9
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 00:54:57 -0700 (PDT)
In-Reply-To: <1412150148-9991-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Route entry will be free on error by vport when freeing skb.
additional error check and free after xmit() will cause double free.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 datapath/vport-vxlan.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/datapath/vport-vxlan.c b/datapath/vport-vxlan.c
index 8689853..44968d0 100644
--- a/datapath/vport-vxlan.c
+++ b/datapath/vport-vxlan.c
@@ -180,8 +180,6 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 			     tun_key->ipv4_ttl, df,
 			     src_port, dst_port,
 			     htonl(be64_to_cpu(tun_key->tun_id) << 8));
-	if (err < 0)
-		ip_rt_put(rt);
 error:
 	return err;
 }
-- 
1.9.1
