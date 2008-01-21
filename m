From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [IPV4] ipmr sparse warnings
Date: Mon, 21 Jan 2008 09:53:09 -0800
Message-ID: <20080121095309.088b044e@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:57330 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751569AbYAUR4S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 12:56:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of some of the sparse warnings.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/ipmr.c	2008-01-21 09:37:02.000000000 -0800
+++ b/net/ipv4/ipmr.c	2008-01-21 09:39:56.000000000 -0800
@@ -141,7 +141,7 @@ struct net_device *ipmr_new_tunnel(struc
 		p.iph.ihl = 5;
 		p.iph.protocol = IPPROTO_IPIP;
 		sprintf(p.name, "dvmrp%d", v->vifc_vifi);
-		ifr.ifr_ifru.ifru_data = (void*)&p;
+		ifr.ifr_ifru.ifru_data = (__force void __user *)&p;
 
 		oldfs = get_fs(); set_fs(KERNEL_DS);
 		err = dev->do_ioctl(dev, &ifr, SIOCADDTUNNEL);
@@ -954,10 +954,12 @@ int ip_mroute_setsockopt(struct sock *sk
 #ifdef CONFIG_IP_PIMSM
 	case MRT_PIM:
 	{
-		int v, ret;
+		int v;
+
 		if (get_user(v,(int __user *)optval))
 			return -EFAULT;
-		v = (v)?1:0;
+		v = (v) ? 1 : 0;
+
 		rtnl_lock();
 		ret = 0;
 		if (v != mroute_do_pim) {
@@ -1659,6 +1661,7 @@ static struct vif_device *ipmr_vif_seq_i
 }
 
 static void *ipmr_vif_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(mrt_lock)
 {
 	read_lock(&mrt_lock);
 	return *pos ? ipmr_vif_seq_idx(seq->private, *pos - 1)
@@ -1682,6 +1685,7 @@ static void *ipmr_vif_seq_next(struct se
 }
 
 static void ipmr_vif_seq_stop(struct seq_file *seq, void *v)
+	__releases(mrt_lock)
 {
 	read_unlock(&mrt_lock);
 }
