From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next]  igmp: remove useless (void) cast
Date: Fri, 31 May 2013 18:44:38 -0700
Message-ID: <20130531184438.21966f63@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:41153 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755625Ab3FABom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 21:44:42 -0400
Received: by mail-pd0-f171.google.com with SMTP id z11so3060315pdj.2
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 18:44:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Back in the old Unix lint days, it was common to put (void) in front
of functions when return value was being ignored. Now this is considered
unnecessary, catch up with the fashion.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/ipv4/igmp.c	2013-05-31 08:35:07.838917459 -0700
+++ b/net/ipv4/igmp.c	2013-05-31 08:37:21.345081065 -0700
@@ -633,7 +633,7 @@ static void igmpv3_send_cr(struct in_dev
 
 	if (!skb)
 		return;
-	(void) igmpv3_sendpack(skb);
+	igmpv3_sendpack(skb);
 }
 
 static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
@@ -1733,7 +1733,7 @@ static int ip_mc_add_src(struct in_devic
 		if (!delta)
 			pmc->sfcount[sfmode]--;
 		for (j=0; j<i; j++)
-			(void) ip_mc_del1_src(pmc, sfmode, &psfsrc[j]);
+			ip_mc_del1_src(pmc, sfmode, &psfsrc[j]);
 	} else if (isexclude != (pmc->sfcount[MCAST_EXCLUDE] != 0)) {
 #ifdef CONFIG_IP_MULTICAST
 		struct ip_sf_list *psf;
@@ -1887,7 +1887,7 @@ int ip_mc_leave_group(struct sock *sk, s
 				iml->multi.imr_address.s_addr)
 			continue;
 
-		(void) ip_mc_leave_src(sk, iml, in_dev);
+		ip_mc_leave_src(sk, iml, in_dev);
 
 		*imlp = iml->next_rcu;
 
@@ -2106,18 +2106,18 @@ int ip_mc_msfilter(struct sock *sk, stru
 		}
 	} else {
 		newpsl = NULL;
-		(void) ip_mc_add_src(in_dev, &msf->imsf_multiaddr,
+		ip_mc_add_src(in_dev, &msf->imsf_multiaddr,
 				     msf->imsf_fmode, 0, NULL, 0);
 	}
 	psl = rtnl_dereference(pmc->sflist);
 	if (psl) {
-		(void) ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
+		ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
 			psl->sl_count, psl->sl_addr, 0);
 		/* decrease mem now to avoid the memleak warning */
 		atomic_sub(IP_SFLSIZE(psl->sl_max), &sk->sk_omem_alloc);
 		kfree_rcu(psl, rcu);
 	} else
-		(void) ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
+		ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
 			0, NULL, 0);
 	rcu_assign_pointer(pmc->sflist, newpsl);
 	pmc->sfmode = msf->imsf_fmode;
@@ -2307,7 +2307,7 @@ void ip_mc_drop_socket(struct sock *sk)
 
 		inet->mc_list = iml->next_rcu;
 		in_dev = inetdev_by_index(net, iml->multi.imr_ifindex);
-		(void) ip_mc_leave_src(sk, iml, in_dev);
+		ip_mc_leave_src(sk, iml, in_dev);
 		if (in_dev != NULL)
 			ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
 		/* decrease mem now to avoid the memleak warning */
