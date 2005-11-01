From: Yan Zheng <yanzheng@21cn.com>
Subject: Re: [PATCH][MCAST]IPv6: small fix for ip6_mc_msfilter(...)
Date: Wed, 02 Nov 2005 07:49:54 +0800
Message-ID: <4367FF22.3030601@21cn.com>
References: <OF395F8772.5B834BF9-ON882570AC.0075ACD7-882570AC.0075DC3C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751452AbVKAXsX@vger.kernel.org>
To: netdev@vger.kernel.org
In-Reply-To: <OF395F8772.5B834BF9-ON882570AC.0075ACD7-882570AC.0075DC3C@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> Yan,
>         Please also make this equivalent change in IPv4 with
> ip_mc_msfilter() and ip_mc_add_src().
> 
>                                                 +-DLS
> 
> Acked-by: David L Stevens <dlstevens@us.ibm.com> 

To keep code style, I also create a new patch for IPv6. :-)

Signed-off-by: Yan Zheng <yanzheng@21cn.com>

Patch for IPv4
Index:net/ipv4/igmp.c
============================================================
--- linux-2.6.14/net/ipv4/igmp.c	2005-10-28 08:02:08.000000000 +0800
+++ linux/net/ipv4/igmp.c	2005-11-02 07:31:01.000000000 +0800
@@ -1908,8 +1908,11 @@ int ip_mc_msfilter(struct sock *sk, stru
			sock_kfree_s(sk, newpsl, IP_SFLSIZE(newpsl->sl_max));
			goto done;
		}
-	} else
+	} else {
		newpsl = NULL;
+		(void) ip_mc_add_src(in_dev, &msf->imsf_multiaddr,
+			msf->imsf_fmode, 0, NULL, 0)
+	}
	psl = pmc->sflist;
	if (psl) {
		(void) ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,




Patch for IPv6
Index:net/ipv6/mcast.c
============================================================
--- linux-2.6.14/net/ipv6/mcast.c	2005-10-30 23:09:33.000000000 +0800
+++ linux/net/ipv6/mcast.c	2005-11-02 07:19:12.000000000 +0800
@@ -545,8 +545,10 @@ int ip6_mc_msfilter(struct sock *sk, str
			sock_kfree_s(sk, newpsl, IP6_SFLSIZE(newpsl->sl_max));
			goto done;
		}
-	} else
+	} else {
		newpsl = NULL;
+		(void) ip6_mc_add_src(idev, group, gsf->gf_fmode, 0, NULL, 0);
+	}
	psl = pmc->sflist;
	if (psl) {
		(void) ip6_mc_del_src(idev, group, pmc->sfmode,
