From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: [PATCH-RESEND] Removing unneeded statement from tcp_ipv4.c
Date: Thu, 06 Mar 2008 11:46:36 +0100
Message-ID: <47CFCB8C.5070801@nets.rwth-aachen.de>
References: <47CBFBDA.7000801@nets.rwth-aachen.de>
 <Pine.LNX.4.64.0803031603100.28251@kivilampi-30.cs.helsinki.fi>
 <47CC872F.9020202@nets.rwth-aachen.de>
 <20080305.190003.22581298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:55833 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763263AbYCFKpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 05:45:22 -0500
In-reply-to: <20080305.190003.22581298.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller schrieb:
> From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
> Date: Tue, 04 Mar 2008 00:18:07 +0100
> 
>> Avoid setting tstamp_ok because this is done two lines later anyway.
>>
>> Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
> 
> Patch does not apply, your email client has corrupted the
> patch by turning tabs into spaces etc.
> 
Sorry, this one should apply.

Avoid setting tstamp_ok because this is done two lines later anyway.

Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 00156bf..ecef356 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1302,15 +1302,14 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		tmp_opt.saw_tstamp = 0;
 	}

-	if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval) {
-		/* Some OSes (unknown ones, but I see them on web server, which
-		 * contains information interesting only for windows'
-		 * users) do not send their stamp in SYN. It is easy case.
-		 * We simply do not advertise TS support.
-		 */
+	/* Some OSes (unknown ones, but I see them on web server, which
+	 * contains information interesting only for windows'
+	 * users) do not send their stamp in SYN. It is easy case.
+	 * We simply do not advertise TS support.
+	 */
+	if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval)
 		tmp_opt.saw_tstamp = 0;
-		tmp_opt.tstamp_ok  = 0;
-	}
+	
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;

 	tcp_openreq_init(req, &tmp_opt, skb);
