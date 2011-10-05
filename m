From: =?iso-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Subject: RE: netfilter: Use proper rwlock init function
Date: Wed, 5 Oct 2011 15:54:07 +0200
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D90314C@ESESSCMS0356.eemea.ericsson.se>
References: <alpine.LFD.2.02.1110051522410.18778@ionos>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>
To: Thomas Gleixner <tglx@linutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Julian Anastasov <ja@ssi.bg>,
	"horms@verge.net.au" <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:45526 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658Ab1JENyZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 09:54:25 -0400
In-Reply-To: <alpine.LFD.2.02.1110051522410.18778@ionos>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Simon,
you can drop my "fix lockdep warning" patch
since Thomas patch is identical to what I prepared to send...

>Replace the open coded initialization with the init function.
>
>Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Ack-by: Hans Schillstrom <hans.schillstrom@ericsson.com>

>---
> net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>Index: linux-2.6/net/netfilter/ipvs/ip_vs_ctl.c
>===================================================================
>--- linux-2.6.orig/net/netfilter/ipvs/ip_vs_ctl.c
>+++ linux-2.6/net/netfilter/ipvs/ip_vs_ctl.c
>@@ -3679,7 +3679,7 @@ int __net_init __ip_vs_control_init(stru
>        int idx;
>        struct netns_ipvs *ipvs = net_ipvs(net);
>
>-       ipvs->rs_lock = __RW_LOCK_UNLOCKED(ipvs->rs_lock);
>+       rwlock_init(&ipvs->rs_lock);
>
>        /* Initialize rs_table */
>        for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)

Thanks
Hans