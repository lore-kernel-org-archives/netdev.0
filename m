From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, PATCH 4/5]: netfilter+ipsec - policy lookup
Date: Sat, 20 Mar 2004 15:01:55 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <405C4ED3.4030004@trash.net>
References: <20040308110331.GA20719@gondor.apana.org.au> <404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com> <4059CF17.8090907@trash.net> <20040319115130.GE29066@gondor.apana.org.au> <405B2132.6060403@trash.net> <20040319210525.GA479@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040319210525.GA479@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> 
> Actually it was me who was confused.  ip_route_me_harder can be called
> on both incoming/outgoing packets.  That's what the if clause is trying
> to determine.  You should only call xfrm_lookup on the outgoing path.

No, ip_route_me_harder is currently (without the patches) only called
for outgoing packets. The if-clause is there because ip_route_output
doesn't handle packets with non-local source, and we don't want to set
the source to 0 (as was done before) because it prevents policy routing
from working properly. That's why we need the xfrm_lookup for both
cases.

Regards
Patrick

> 
> So this should be moved back to the if clause above:
> 
> 		fl.proto = iph->protocol;
> 		lookup = __ip_route_output_key;
> #ifdef CONFIG_XFRM
> 		if (!(IPCB(*pskb)->flags & IPSKB_XFRM_TRANSFORMED)) {
> 			lookup = ip_route_output_key;
> 			do_decode
> 		}
> #endif
> 		if (lookup(&rt, &fl) != 0)
> 			return -1;
