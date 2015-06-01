From: Willy Tarreau <w@1wt.eu>
Subject: Re: 2.6.32.66 tcp regression OOPs
Date: Mon, 1 Jun 2015 09:49:22 +0200
Message-ID: <20150601074922.GA28740@1wt.eu>
References: <6.2.5.6.2.20150531210751.0722ad10@binnacle.cx> <CAH6sp9O9sqKuamwF38JZLh+K2QKXNB7RRJ8cPtz+1h6MV7foYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: starlight.2015q2@binnacle.cx,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Frans Klaver <fransklaver@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:55090 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936AbbFAHt2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2015 03:49:28 -0400
Content-Disposition: inline
In-Reply-To: <CAH6sp9O9sqKuamwF38JZLh+K2QKXNB7RRJ8cPtz+1h6MV7foYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Jun 01, 2015 at 09:00:21AM +0200, Frans Klaver wrote:
> [cc: Willy Tarreau]
> 
> On Mon, Jun 1, 2015 at 3:26 AM,  <starlight.2015q2@binnacle.cx> wrote:
> > Hello,
> >
> > Apoligies if I have submitted to the wrong lists.
> >
> > Encountered a regression in
> > 2.6.32.66 relative to 2.6.32.65.
> >
> > Crash eight minutes after boot.
> >
> > Will responded with additional details
> > if the OOPS is not sufficent.
> >
> > Best Regards
> >
> 
> Did you bisect it?

Eric Dumazet notified me that of something possibly similar due to
a mistake I made when backporting a fix by hand.

Please apply the following patch to see if it fixes the problem :

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c                      
index 5339f066234b..d1e2895bb63c 100644                                         
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2136,7 +2136,7 @@ void tcp_send_fin(struct sock *sk)
	 */
	if (tskb && (tcp_send_head(sk) || tcp_memory_pressure)) {
 coalesce:
-		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_FIN;
+		TCP_SKB_CB(tskb)->flags |= TCPCB_FLAG_FIN;
		TCP_SKB_CB(tskb)->end_seq++;
		tp->write_seq++;
	if (!tcp_send_head(sk)) {

Thanks,
Willy
