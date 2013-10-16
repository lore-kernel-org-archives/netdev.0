From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by IPVS
Date: Tue, 15 Oct 2013 19:40:59 -0700
Message-ID: <1381891259.2045.100.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au>
	 <1381882426.2045.85.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131016002807.GM22321@verge.net.au>
	 <1381883949.2045.97.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131016021304.GA17801@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>,
	Mark Brooks <mark@loadbalancer.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20131016021304.GA17801@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-10-16 at 11:13 +0900, Simon Horman wrote:

> That does seem very promising but while implementing it
> I hit a problem.
> 
> struct tcp_skb_cb includes a field of type struct inet6_skb_parm.  And
> expanding struct inet6_skb_parm by 16 bytes means that struct tcp_skb_cb is
> now larger than 48 bytes and no longer fits in skb->cb.
> 
> Is it appropriate to grow skb->cb as the comment above struct tcp_skb_cb
> suggests?

Ah well...

No, its not appropriate to grow sk_buff by 16 bytes, sorry.

You could not change struct inet6_skb_parm, but define IP6CB as
a compound 

struct ip6cb {
   struct inet6_skb_parm foo;
   struct in6_addr       bar;
};



