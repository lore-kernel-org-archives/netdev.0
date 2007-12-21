From: David Miller <davem@davemloft.net>
Subject: Re: [TCP] tcp_write_timeout.c cleanup
Date: Fri, 21 Dec 2007 04:30:26 -0800 (PST)
Message-ID: <20071221.043026.19571736.davem@davemloft.net>
References: <476B5581.6040603@cosmosbay.com>
	<20071221122316.GU6264@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35871
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750723AbXLUMa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 07:30:27 -0500
In-Reply-To: <20071221122316.GU6264@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 21 Dec 2007 10:23:16 -0200

> Em Fri, Dec 21, 2007 at 06:56:17AM +0100, Eric Dumazet escreveu:
> > +static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
> > +{
> > +	int mss;
> -       int mss;
> 		
> > +
> > +	/* Black hole detection */
> > +	if (sysctl_tcp_mtu_probing) {
> > +		if (!icsk->icsk_mtup.enabled) {
> > +			icsk->icsk_mtup.enabled = 1;
> > +			tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
> > +		} else {
> > +			struct tcp_sock *tp = tcp_sk(sk);
> +			int mss;
> > +			mss = tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low)/2;

I've checked in this, ummm... patch :-)

commit 323f3f2f31840f94e540ec5a0ce33593d05dd8d9
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Fri Dec 21 04:29:16 2007 -0800

    [TCP]: Move mss variable in tcp_mtu_probing()
    
    Down into the only scope where it is used.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 8f14808..ea111e9 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -116,8 +116,6 @@ static int tcp_orphan_retries(struct sock *sk, int alive)
 
 static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
 {
-	int mss;
-
 	/* Black hole detection */
 	if (sysctl_tcp_mtu_probing) {
 		if (!icsk->icsk_mtup.enabled) {
@@ -125,6 +123,8 @@ static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
 			tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 		} else {
 			struct tcp_sock *tp = tcp_sk(sk);
+			int mss;
+
 			mss = tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low)/2;
 			mss = min(sysctl_tcp_base_mss, mss);
 			mss = max(mss, 68 - tp->tcp_header_len);
