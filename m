From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 4.4-rc2 xfrm_lookup kasan trace
Date: Thu, 03 Dec 2015 09:09:38 -0800
Message-ID: <1449162578.25029.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151130232733.GA27119@codemonkey.org.uk>
	 <1448932931.25582.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151203.115918.730123340200500473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35779 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689AbbLCRJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 12:09:41 -0500
Received: by pacej9 with SMTP id ej9so72098362pac.2
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 09:09:40 -0800 (PST)
In-Reply-To: <20151203.115918.730123340200500473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-12-03 at 11:59 -0500, David Miller wrote:
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

Agreed, it is sad C language has no way to 'propagate' the const..
