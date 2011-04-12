From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bridge: reset IPCB in br_parse_ip_options
Date: Tue, 12 Apr 2011 19:18:40 +0200
Message-ID: <1302628720.3233.84.camel@edumazet-laptop>
References: <4DA3F909.5020609@scotdoyle.com>
	 <1302608951.3233.33.camel@edumazet-laptop>
	 <1302613353.30934.22.camel@polaris.local>
	 <1302614145.3233.47.camel@edumazet-laptop>
	 <1302617968.30934.34.camel@polaris.local>
	 <1302619749.3233.56.camel@edumazet-laptop>
	 <1302621233.30934.44.camel@polaris.local>
	 <1302624851.3233.63.camel@edumazet-laptop>
	 <20110412092039.69f420f6@nehalam>
	 <1302626152.3233.66.camel@edumazet-laptop>
	 <20110412164557.GF2047@stratus.com>
	 <1302627281.3233.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jan =?ISO-8859-1?Q?L=FCbbe?= <jluebbe@debian.org>,
	Scot Doyle <lkml@scotdoyle.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org, Bandan Das <bandan.das@stratus.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40029 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932106Ab1DLRSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 13:18:44 -0400
Received: by wwa36 with SMTP id 36so8166745wwa.1
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 10:18:43 -0700 (PDT)
In-Reply-To: <1302627281.3233.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 462fb2af9788a82 (bridge : Sanitize skb before it enters the IP
stack), missed one IPCB init before calling ip_options_compile()

Thanks to Scot Doyle for his tests and bug reports.

Reported-by: Scot Doyle <lkml@scotdoyle.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Acked-by: Bandan Das <bandan.das@stratus.com>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
Cc: Jan L=C3=BCbbe <jluebbe@debian.org>
---
 net/bridge/br_netfilter.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 008ff6c..b353f7c 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -249,11 +249,9 @@ static int br_parse_ip_options(struct sk_buff *skb=
)
 		goto drop;
 	}
=20
-	/* Zero out the CB buffer if no options present */
-	if (iph->ihl =3D=3D 5) {
-		memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+	if (iph->ihl =3D=3D 5)
 		return 0;
-	}
=20
 	opt->optlen =3D iph->ihl*4 - sizeof(struct iphdr);
 	if (ip_options_compile(dev_net(dev), opt, skb))


