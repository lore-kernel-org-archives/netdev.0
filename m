From: Koichiro Den <den@klaipeden.com>
Subject: Re: [net-next] tcp: do tcp_mstamp_refresh before retransmits on TSQ
 handler
Date: Sun, 22 Oct 2017 13:10:19 +0900
Message-ID: <1508645419.9317.7.camel@klaipeden.com>
References: <20171022033808.12641-1-den@klaipeden.com>
         <1508644334.30291.38.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21304 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750779AbdJVEKY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 00:10:24 -0400
In-Reply-To: <1508644334.30291.38.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-10-21 at 20:52 -0700, Eric Dumazet wrote:
> On Sun, 2017-10-22 at 12:38 +0900, Koichiro Den wrote:
> > When retransmission on TSQ handler was introduced in the commit
> > f9616c35a0d7 ("tcp: implement TSQ for retransmits"), the retransmitted
> > skbs' timestamps were updated on the actual transmission. In the later
> > commit 385e20706fac ("tcp: use tp->tcp_mstamp in output path"), it stops
> > being done so. In the commit, the comment says "We try to refresh
> > tp->tcp_mstamp only when necessary", and at present tcp_tsq_handler and
> > tcp_v4_mtu_reduced applies to this. About the latter, it's okay since
> > it's rare enough.
> > 
> > About the former, even though possible retransmissions on the tasklet
> > comes just after the destructor run in NET_RX softirq handling, the time
> > between them could be nonnegligibly large to the extent that
> > tcp_rack_advance or rto rearming be affected if other (remaining) RX,
> > BLOCK and (preceding) TASKLET sofirq handlings are unexpectedly heavy.
> > 
> > So in the same way as tcp_write_timer_handler does, doing tcp_mstamp_refresh
> > ensures the accuracy of algorithms relying on it.
> > 
> > Signed-off-by: Koichiro Den <den@klaipeden.com>
> > ---
> >  net/ipv4/tcp_output.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> Very nice catch, thanks a lot Koichiro.
> 
> This IMO would target net tree, since it is a bug fix.
> 
> Fixes: 385e20706fac ("tcp: use tp->tcp_mstamp in output path")
Ok I will submit it to net tree. Thanks!
> 
> Thanks !
> 
> We should have caught that in our regression packetdrill tests...
In its "remote" mode testing not relying on tun xmit, I agree it could be
caught. If it's better to write, test and attach the script, please let me know.

Thank you.
