From: Yan Zheng <yanzheng@21cn.com>
Subject: [PATCH][MCAST]IPv6: small fix for ip6_mc_msfilter(...)
Date: Mon, 31 Oct 2005 10:52:32 +0800
Message-ID: <436586F0.9080101@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751292AbVJaCvM@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.
I think ip6_mc_add_src(...) should be called when number of sources is zero and filter mode is exclude.

Regards



Signed-off-by: Yan Zheng <yanzheng@21cn.com> 

Index: net/ipv6/mcast.c
================================================================================
--- linux-2.6.14/net/ipv6/mcast.c	2005-10-30 23:09:33.000000000 +0800
+++ linux/net/ipv6/mcast.c	2005-10-31 10:37:36.000000000 +0800
@@ -545,8 +545,10 @@ int ip6_mc_msfilter(struct sock *sk, str
 			sock_kfree_s(sk, newpsl, IP6_SFLSIZE(newpsl->sl_max));
 			goto done;
 		}
-	} else
+	} else {
 		newpsl = NULL;
+		ip6_mc_add_src(idev, group, gsf->gf_fmode, 0, NULL, 0);
+	}
 	psl = pmc->sflist;
 	if (psl) {
 		(void) ip6_mc_del_src(idev, group, pmc->sfmode,
