From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: 4.4-rc2 xfrm_lookup kasan trace
Date: Tue, 8 Dec 2015 14:35:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBE87BE@AcuExch.aculab.com>
References: <20151130232733.GA27119@codemonkey.org.uk>
	<1448932931.25582.2.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151203.115918.730123340200500473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davej@codemonkey.org.uk" <davej@codemonkey.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.194]:50362 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756813AbbLHOh0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 09:37:26 -0500
In-Reply-To: <20151203.115918.730123340200500473.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Of David Miller
> Sent: 03 December 2015 16:59
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 30 Nov 2015 17:22:11 -0800
> 
> > @@ -2198,6 +2198,7 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
> >  	xdst = NULL;
> >  	route = NULL;
> >
> > +	sk = sk_to_full_sk((struct sock *)sk);
> 
> The war against const...
> 
> I know this is the only instance where const is input, but you may want to
> consider adding the const verion of the helper anyways to avoid ugly casts
> like this.

In that case you could use something like:

#define SK_TO_FULL_SK(sk) (typeof (sk))sk_to_full_sk(sk))

With the helper arg and result being 'const struct sock *'.

	David
