From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Thu, 27 May 2010 21:19:44 +0200
Message-ID: <20100527191944.GD2728@nuttenaction>
References: <20100526212745.GC24615@basil.fritz.box>
 <20100526.151014.70204145.davem@davemloft.net>
 <20100526231512.GD2684@nuttenaction>
 <20100526.200443.232751390.davem@davemloft.net>
 <20100527070827.GB2728@nuttenaction>
 <AANLkTime8wfTLfdNMAx_HYr6XO0DiO12r5FVdGBjVNwT@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	shemminger@vyatta.com, netdev@vger.kernel.org, ycheng@google.com,
	lars.eggert@nokia.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:35554 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756792Ab0E0TTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 15:19:46 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTime8wfTLfdNMAx_HYr6XO0DiO12r5FVdGBjVNwT@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Tom Herbert | 2010-05-27 09:14:09 [-0700]:

>"When web browsers open simultaneous TCP connections to the same
>destination, they are working against TCP's congestion control
>mechanisms"

Right, the problem can applied for other protocols as well. Often p2p
protocols behave unfair. This problem is known, but there is currently no
IETF effort to address the problem. The problem is not that simple and it is
difficult to draft a universal statement.

>I have yet to find any paper on CWND that analyzed the effect of this
>phenomena on the Internet which is quite unfortunate.  In our own full
>scale experiments
>(http://code.google.com/speed/articles/tcp_initcwnd_paper.pdf), we
>anlayzed the effects of using larger initial congestion windows on the
>Internet which might be the closest thing to such an analysis.  I know
>in LEDBAT WG of IETF they are trying to come up with new
>recommendations for number of connections a browser can open, this is
>good but I hope it's not after the fact.

I know your paper and if I remember correctly I was a little bit sceptical
about the efforts to analyze the fairness behavior in deep. It takes one day
to validate the fairness issues: take NS3 (with NSC so you can take the Linux
network stack with your patch), setup a dumpbell topology and analyse the
behavior. I will read the paper one more time.

I had no problem with you patch if you apply this patch on top of it:  ;-)


diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0ca9832..73f9d46 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2371,7 +2371,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		break;
 
 	case TCP_CWND:
-		if (sysctl_tcp_user_cwnd_max <= 0)
+		if (sysctl_tcp_user_cwnd_max <= 0 || !capable(CAP_NET_ADMIN))
 			err = -EPERM;
 		else if (val > 0 && sk->sk_state == TCP_ESTABLISHED &&
 		    icsk->icsk_ca_state == TCP_CA_Open) {


HGN
