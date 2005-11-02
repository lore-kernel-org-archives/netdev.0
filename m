From: Yan Zheng <yanzheng@21cn.com>
Subject: Re: [PATCH][MCAST]IPv6: small fix for ip6_mc_msfilter(...)
Date: Thu, 03 Nov 2005 07:28:20 +0800
Message-ID: <43694B94.7010605@21cn.com>
References: <OF395F8772.5B834BF9-ON882570AC.0075ACD7-882570AC.0075DC3C@us.ibm.com>	 <4367FF22.3030601@21cn.com> <39e6f6c70511021355i52aff7e4n19ca4c1e24b21bb7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965339AbVKBX0e@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
In-Reply-To: <39e6f6c70511021355i52aff7e4n19ca4c1e24b21bb7@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> Could you please compile test it next time :-) hint, missing ';'.
> Anyway, fixed up by hand.
> 
> - Arnaldo
> 
> 

I'm so sorry. 

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
+			msf->imsf_fmode, 0, NULL, 0);
+	}
	psl = pmc->sflist;
	if (psl) {
		(void) ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
