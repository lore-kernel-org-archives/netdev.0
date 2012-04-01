From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: check the length of the data before
 dereferencing it
Date: Sun, 01 Apr 2012 18:55:22 +0200
Message-ID: <1333299322.2325.5277.camel@edumazet-glaptop>
References: <1333290170-26898-1-git-send-email-xiaosuo@gmail.com>
	 <20120401164325.GB10861@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120401164325.GB10861@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-04-01 at 18:43 +0200, Pablo Neira Ayuso wrote:
> On Sun, Apr 01, 2012 at 10:22:50PM +0800, Changli Gao wrote:
> > We should check the length of the data before dereferencing it when parsing
> > the TCP options.
> > 
> > Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> > ---
> >  net/netfilter/nf_conntrack_proto_tcp.c |    4 ++++
> >  1 file changed, 4 insertions(+)
> > diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
> > index 361eade..9e446c5 100644
> > --- a/net/netfilter/nf_conntrack_proto_tcp.c
> > +++ b/net/netfilter/nf_conntrack_proto_tcp.c
> > @@ -404,6 +404,8 @@ static void tcp_options(const struct sk_buff *skb,
> >  			length--;
> >  			continue;
> >  		default:
> > +			if (length < 2)
> > +				return;
> >  			opsize=*ptr++;
> >  			if (opsize < 2) /* "silly options" */
> >  				return;
> 
> length is always multiple of 4:
> 
> int length = (tcph->doff*4) - sizeof(struct tcphdr);
> --

initial value yes, but it can change in the loop.


