From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] tcp: tcp_sendmsg() wrong access to sk_route_caps
Date: Mon, 28 Nov 2011 16:53:36 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AEEB@saturn3.aculab.com>
References: <1322496298.2292.76.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>,
	"Michal Miroslaw" <mirq-linux@rere.qmqm.pl>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44684 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752116Ab1K1Qzh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 11:55:37 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21829-04 for <netdev@vger.kernel.org>;
 Mon, 28 Nov 2011 16:55:32 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1322496298.2292.76.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> > > -	sg = sk->sk_route_caps & NETIF_F_SG;
> > > +	sg = !!(sk->sk_route_caps & NETIF_F_SG);
> > 
> > As sg is now bool, using !! is unnecessary.
> > 
> > A commit was done recently to remove one.
> > 3ad9b358e03fd9dbf6705721490c811b666b0fe2
> > 
> 
> Hmm... I find it dangerous and error prone. Obviously not at 
> the time we
> commit such changes, but later, because a future reader might 
> be fooled.
> 
> Using !!(expr) is pretty clear about the potential problem, and
> generates no extra code if a bool is used for the target.

Or leave 'sg' as 'unsigned int' and add:
    COMPILE_ASSERT(NETIF_F_SG & ~0);
(or however linux spells the appropriate define)

	David
