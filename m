From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ipv6: addrconf sparse warnings
Date: Sun, 20 Jan 2008 10:01:40 -0800
Message-ID: <20080120100140.0f5e2fce@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ?=
	 =?UTF-8?B?6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:35446 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755341AbYATSEq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2008 13:04:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of a couple of sparse warnings in IPV6 addrconf code.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/addrconf.c	2008-01-20 09:38:06.000000000 -0800
+++ b/net/ipv6/addrconf.c	2008-01-20 09:57:40.000000000 -0800
@@ -1900,7 +1900,7 @@ int addrconf_set_dstaddr(void __user *ar
 		p.iph.ihl = 5;
 		p.iph.protocol = IPPROTO_IPV6;
 		p.iph.ttl = 64;
-		ifr.ifr_ifru.ifru_data = (void __user *)&p;
+		ifr.ifr_ifru.ifru_data = (__force void __user *)&p;
 
 		oldfs = get_fs(); set_fs(KERNEL_DS);
 		err = dev->do_ioctl(dev, &ifr, SIOCADDTUNNEL);
@@ -2799,6 +2799,7 @@ static struct inet6_ifaddr *if6_get_idx(
 }
 
 static void *if6_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(addrconf_hash_lock)
 {
 	read_lock_bh(&addrconf_hash_lock);
 	return if6_get_idx(seq, *pos);
@@ -2814,6 +2815,7 @@ static void *if6_seq_next(struct seq_fil
 }
 
 static void if6_seq_stop(struct seq_file *seq, void *v)
+	__releases(addrconf_hash_lock)
 {
 	read_unlock_bh(&addrconf_hash_lock);
 }
