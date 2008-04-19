From: David Miller <davem@davemloft.net>
Subject: Re: [bug] build failure in net/netfilter/nf_conntrack_sip.c, on
 latest -git
Date: Sat, 19 Apr 2008 03:07:36 -0700 (PDT)
Message-ID: <20080419.030736.168169087.davem@davemloft.net>
References: <20080419100034.GA9475@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54919
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753484AbYDSKHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 06:07:37 -0400
In-Reply-To: <20080419100034.GA9475@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Sat, 19 Apr 2008 12:00:35 +0200

[ netfilter-devel and netdev added to CC: ]

> randconfig testing found a netfilter build failure in latest -git:
> 
>   net/netfilter/nf_conntrack_sip.c: In function 'set_expected_rtp_rtcp':
>   net/netfilter/nf_conntrack_sip.c:786: error: 'struct nf_conntrack_expect' has no member named 'saved_ip'
> 
>   http://redhat.com/~mingo/misc/config-Sat_Apr_19_11_37_02_CEST_2008.bad
> 
> disabling CONFIG_NF_CONNTRACK_SIP works it around.

I think this will fix it.

Patrick, is this how we should do it?

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index c1fc0f1..fd60b2b 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -245,7 +245,7 @@ config NF_CONNTRACK_SANE
 
 config NF_CONNTRACK_SIP
 	tristate "SIP protocol support"
-	depends on NF_CONNTRACK
+	depends on NF_CONNTRACK && NF_NAT
 	default m if NETFILTER_ADVANCED=n
 	help
 	  SIP is an application-layer control protocol that can establish,
