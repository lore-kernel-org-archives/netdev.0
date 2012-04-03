From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xt_CT: remove a compile warning
Date: Tue, 3 Apr 2012 10:17:28 +0200
Message-ID: <20120403081728.GA19753@1984>
References: <1333424902.18626.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ZoaI/ZTpAVc4A5k6"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54942 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751212Ab2DCIRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 04:17:35 -0400
Content-Disposition: inline
In-Reply-To: <1333424902.18626.36.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZoaI/ZTpAVc4A5k6
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Tue, Apr 03, 2012 at 05:48:22AM +0200, Eric Dumazet wrote:
> If CONFIG_NF_CONNTRACK_TIMEOUT=n we have following warning :
> 
>   CC [M]  net/netfilter/xt_CT.o
> net/netfilter/xt_CT.c: In function ‘xt_ct_tg_check_v1’:
> net/netfilter/xt_CT.c:284: warning: label ‘err4’ defined but not used

Thanks Eric.

I think I prefer the one attached.

I 'll pass it to davem with a couple of other minor fixes anytime soon.

--ZoaI/ZTpAVc4A5k6
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: attachment; filename="0001-netfilter-xt_CT-remove-a-compile-warning.patch"
Content-Transfer-Encoding: 8bit

>From 44b52bccf855b0706de624c29fc3d82ca954bb4e Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 3 Apr 2012 10:08:48 +0200
Subject: [PATCH] netfilter: xt_CT: remove a compile warning
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

If CONFIG_NF_CONNTRACK_TIMEOUT=n we have following warning :

  CC [M]  net/netfilter/xt_CT.o
net/netfilter/xt_CT.c: In function ‘xt_ct_tg_check_v1’:
net/netfilter/xt_CT.c:284: warning: label ‘err4’ defined but not used

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 0c8e438..138b75e 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -281,8 +281,10 @@ out:
 	info->ct = ct;
 	return 0;
 
+#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
 err4:
 	rcu_read_unlock();
+#endif
 err3:
 	nf_conntrack_free(ct);
 err2:
-- 
1.7.2.5


--ZoaI/ZTpAVc4A5k6--
