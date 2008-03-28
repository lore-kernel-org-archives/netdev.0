From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH 2/11 net-2.6.26] [DCCP]: Replace socket with sock for
	reset sending.
Date: Fri, 28 Mar 2008 18:08:42 +0300
Message-ID: <1206716922.4294.0.camel@iris.sw.ru>
References: <1206695071.3271.8.camel@iris.sw.ru>
	 <1206695338-5947-2-git-send-email-den@openvz.org>
	 <20080328143959.GT14945@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39309 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753052AbYC1PIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 11:08:34 -0400
In-Reply-To: <20080328143959.GT14945@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-03-28 at 11:39 -0300, Arnaldo Carvalho de Melo wrote:
> Em Fri, Mar 28, 2008 at 12:08:49PM +0300, Denis V. Lunev escreveu:
> > Replace dccp_v(4|6)_ctl_socket with sock to unify a code with TCP/ICMP.
> > 
> > Signed-off-by: Denis V. Lunev <den@openvz.org>
> > ---
> >  net/dccp/ipv4.c |   16 +++++++++-------
> >  net/dccp/ipv6.c |   10 ++++++----
> >  2 files changed, 15 insertions(+), 11 deletions(-)
> > 
> > diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> > index 4ca8b0c..79a9a4a 100644
> > --- a/net/dccp/ipv4.c
> > +++ b/net/dccp/ipv4.c
> > @@ -36,7 +36,7 @@
> >   * the Out-of-the-blue (OOTB) packets. A control sock will be created
> >   * for this socket at the initialization time.
> >   */
> > -static struct socket *dccp_v4_ctl_socket;
> > +static struct sock *dccp_v4_ctl_sk;
> >  
> >  int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
> >  {
> > @@ -514,11 +514,11 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
> >  	if (rxskb->rtable->rt_type != RTN_LOCAL)
> >  		return;
> >  
> > -	dst = dccp_v4_route_skb(dccp_v4_ctl_socket->sk, rxskb);
> > +	dst = dccp_v4_route_skb(dccp_v4_ctl_sk, rxskb);
> >  	if (dst == NULL)
> >  		return;
> >  
> > -	skb = dccp_ctl_make_reset(dccp_v4_ctl_socket, rxskb);
> > +	skb = dccp_ctl_make_reset(dccp_v4_ctl_sk->sk_socket, rxskb);
> 
> Why not make dccp_ctl_make_reset receive a struct sock too? It only uses
> ctl->sk anyway. But I guess that can be on a follow-up patch, could you
> that?

sure!

Thank you for pointing this out :)

Regards,
	Den

