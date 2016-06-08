From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] l2tp: fix configuration passed to
 setup_udp_tunnel_sock()
Date: Wed, 8 Jun 2016 12:35:38 +0200
Message-ID: <20160608103538.GF1592@alphalink.fr>
References: <a8f79b662219b6fdeef7556899051108b9294a15.1465213131.git.g.nault@alphalink.fr>
 <20160607.162017.1294730894994990373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tom@herbertland.com, jchapman@katalix.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:34113 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423670AbcFHKfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 06:35:54 -0400
Content-Disposition: inline
In-Reply-To: <20160607.162017.1294730894994990373.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 04:20:17PM -0700, David Miller wrote:
> From: Guillaume Nault <g.nault@alphalink.fr>
> Date: Mon, 6 Jun 2016 13:48:02 +0200
> 
> > @@ -1581,7 +1581,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
> >  	/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
> >  	tunnel->encap = encap;
> >  	if (encap == L2TP_ENCAPTYPE_UDP) {
> > -		struct udp_tunnel_sock_cfg udp_cfg;
> > +		struct udp_tunnel_sock_cfg udp_cfg = { NULL };
> 
> This assumes that the first member of udp_tunnel_sock_cfg is, and will always
> be, a pointer.
> 
> You could use a named initializer to make this better, but the cleanest way to
> deal with this is to use an empty initializer "{ }", or just plain memset()
> the thing to zero.
> 
Indeed. I'll repost using "{ }" then.
