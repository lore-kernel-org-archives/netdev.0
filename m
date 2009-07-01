From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
	configurable
Date: Wed, 1 Jul 2009 09:15:28 +0800
Message-ID: <20090701011528.GA28676@gondor.apana.org.au>
References: <1246379267.3749.42.camel@blaa> <20090630170027.GA22691@gondor.apana.org.au> <20090630.120608.193727499.davem@davemloft.net> <alpine.LSU.2.00.0906302211300.25417@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, markmc@redhat.com,
	netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.0906302211300.25417@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 30, 2009 at 10:16:35PM +0200, Jan Engelhardt wrote:
>
> It makes sense absolutely. Consider:
> 
> * packet enters bridge
> * NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, ...) is called by nr_netfilter.c
> * (connection tracking entry is set up)
> * let bridging decision be "local delivery"

No, my question is does it ever make sense to use conntrack as
part of bridge netfilter.  That is, do you ever want to test it
in your rules that are run as part of bridge netfilter.

conntrack is inherently a security hole when used as part of
bridging, because it ignores the Ethernet header so two unrelated
connections can be tracked as one.

It used to be an even bigger security hole when we ignored VLAN
and PPPOE headers but at least that's now off by default.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
