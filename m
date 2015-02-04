From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] ip6_gre: fix endianness errors in ip6gre_err
Date: Thu, 5 Feb 2015 00:38:30 +0100
Message-ID: <20150204233830.GA10793@kria>
References: <1423059909-15606-1-git-send-email-sd@queasysnail.net>
 <1423064676.907.137.camel@edumazet-glaptop2.roam.corp.google.com>
 <1423065012.907.138.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:34025 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755890AbbBDXic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 18:38:32 -0500
Content-Disposition: inline
In-Reply-To: <1423065012.907.138.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-02-04, 07:50:12 -0800, Eric Dumazet wrote:
> On Wed, 2015-02-04 at 07:44 -0800, Eric Dumazet wrote:
> > On Wed, 2015-02-04 at 15:25 +0100, Sabrina Dubroca wrote:
> > > info is in network byte order, change it back to host byte order
> > > before use. In particular, the current code sets the MTU of the tunnel
> > > to a wrong (too big) value.
> > > 
> > > Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
> > > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > > ---
> > 
> > Acked-by: Eric Dumazet <edumazet@google.com>
> > 
> 
> 
> BTW, "fl6.flowi6_proto = skb->protocol; " in ip6gre_xmit_other()
> looks suspicious...

Yes, I know that sparse complains about it.  I don't know how to
handle that for now.  ntohs would silence the sparse warning, but we
would still have u8 vs u16.  I'll need to have a closer look.

-- 
Sabrina
