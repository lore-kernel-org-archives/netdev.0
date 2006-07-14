From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: Netem does not work with loopback
Date: Fri, 14 Jul 2006 16:34:30 +0200
Message-ID: <44B7AB76.2030700@yahoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g19.free.fr ([212.27.42.29]:10142 "EHLO smtp3-g19.free.fr")
	by vger.kernel.org with ESMTP id S1161059AbWGNOdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 10:33:32 -0400
Received: from [192.168.0.4] (bar06-2-82-224-157-131.fbx.proxad.net [82.224.157.131])
	by smtp3-g19.free.fr (Postfix) with ESMTP id 2074C48141
	for <netdev@vger.kernel.org>; Fri, 14 Jul 2006 16:33:30 +0200 (CEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Is it a known problem that the Netem qdisc is very unreliable on the 
loopback (unlike on a true NIC)?

This seems to come from its usage of skb->cb which conflicts with IPCB. 
For instance, the field
IPCB(skb)->opt.optlen becomes non-null and memory corruption follows.

I ``worked around'' this conflict with the following ugly hack:

--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -79,6 +79,7 @@ struct netem_sched_data {
 
 /* Time stamp put into socket buffer control block */
 struct netem_skb_cb {
+    char padding[32]; /* to avoid stepping over IPCB when used on the 
loopback */
     psched_time_t    time_to_send;
 };


Hopefully someone has a better solution :-)

Thanks.

-- 
Guillaume

