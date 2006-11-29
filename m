From: David Miller <davem@davemloft.net>
Subject: Re: Broken commit: [NETFILTER]: ipt_REJECT: remove largely
 duplicate route_reverse function
Date: Tue, 28 Nov 2006 20:44:40 -0800 (PST)
Message-ID: <20061128.204440.39160464.davem@davemloft.net>
References: <20061128.202535.112619392.davem@davemloft.net>
	<E1GpHDJ-00059y-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, khc@pm.waw.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56463
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1758789AbWK2Eol (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 23:44:41 -0500
To: herbert@gondor.apana.org.au
In-Reply-To: <E1GpHDJ-00059y-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 29 Nov 2006 15:38:29 +1100

> David Miller <davem@davemloft.net> wrote:
> > 
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 9264139..95e86ac 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -94,7 +94,9 @@ #endif
> > #endif
> > 
> > #if !defined(CONFIG_NET_IPIP) && \
> > -    !defined(CONFIG_IPV6) && !defined(CONFIG_IPV6_MODULE)
> > +    !defined(CONFIG_NET_IPGRE) && \
> > +    !defined(CONFIG_IPV6_SIT) && \
> > +    !defined(CONFIG_IPV6_TUNNEL)
> > #define MAX_HEADER LL_MAX_HEADER
> > #else
> > #define MAX_HEADER (LL_MAX_HEADER + 48)
> 
> What if ipip/gre are modules?

Good catch, I'll fix that up by adding the missing CONFIG_*_MODULE
cases.

Longer term this is really messy, we should handle this some
other way.
