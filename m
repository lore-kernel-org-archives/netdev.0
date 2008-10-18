From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: 2.6.27 [BUG-FIX] [PATCH 1/1] dccp: Port redirection support
	for DCCP
Date: Sat, 18 Oct 2008 12:25:02 -0300
Message-ID: <20081018152502.GJ19353@ghostprotocols.net>
References: <20081018092118.GA22685@gerrit.erg.abdn.ac.uk> <200810181148.14620@nessa> <20081018100651.GA23003@gerrit.erg.abdn.ac.uk> <200810181221.58863@nessa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: KOVACS Krisztian <hidden@sch.bme.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52739 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321AbYJRPZO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2008 11:25:14 -0400
Content-Disposition: inline
In-Reply-To: <200810181221.58863@nessa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sat, Oct 18, 2008 at 12:21:58PM +0200, KOVACS Krisztian escreveu:
> Hi,
> 
> On Saturday 18 October 2008, Gerrit Renker wrote:
> > | I think we're still missing this one:
> > |
> > | diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> > | index 1106278..aa00cdd 100644
> > | --- a/net/dccp/ipv6.c
> > | +++ b/net/dccp/ipv6.c
> > | @@ -558,7 +558,7 @@ static struct sock
> > | *dccp_v6_request_recv_sock(struct sock *sk,
> > | ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
> > |  		fl.oif = sk->sk_bound_dev_if;
> > |  		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
> > | -		fl.fl_ip_sport = inet_sk(sk)->sport;
> > | +		fl.fl_ip_sport = inet_rsk(req)->loc_port;
> > |  		security_sk_classify_flow(sk, &fl);
> > |
> > |  		if (ip6_dst_lookup(sk, &dst, &fl))
> > |
> > | What do you think?
> >
> > Ack - missed this one. Do you want to send your patch or would you like
> > me to send an update for the above?
> 
> Dave & Gerrit, please find the updated patch below.
> 
> - 8< -
> dccp: Port redirection support for DCCP
> 
> Commit a3116ac5c216fc3c145906a46df9ce542ff7dcf2 from 1st October ("tcp: Port
> redirection support for TCP") broke DCCP skb lookup by changing inet_csk_clone,
> which is used by DCCP to generate the child socket after the handshake.
> 
> This patch updates DCCP to use 'loc_port' instead of 'sport', which fixes the
> problem, and thus inheriting port redirection support via the new interface.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>

Good work! Better two fixes than none! :-)

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

- Arnaldo 
