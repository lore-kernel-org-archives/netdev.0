From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: don't scale the size of the window up twice
Date: Tue, 10 Apr 2012 14:35:52 +0200
Message-ID: <20120410123552.GA30763@1984>
References: <1333337106-8279-1-git-send-email-xiaosuo@gmail.com>
 <20120404150854.GA4148@1984>
 <alpine.DEB.2.00.1204042100390.21828@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1204042100390.21828@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 04, 2012 at 09:05:26PM +0200, Jozsef Kadlecsik wrote:
> On Wed, 4 Apr 2012, Pablo Neira Ayuso wrote:
> 
> > On Mon, Apr 02, 2012 at 11:25:06AM +0800, Changli Gao wrote:
> > > For a picked up connection, the window win is scaled twice: one is by the
> > > initialization code, and the other is by the sender updating code.
> > > 
> > > I use the temporary variable swin instead of modifying the variable win.
> > > 
> > > Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> > > ---
> > >  net/netfilter/nf_conntrack_proto_tcp.c |    4 ++--
> > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > > diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
> > > index 361eade..0d07a1d 100644
> > > --- a/net/netfilter/nf_conntrack_proto_tcp.c
> > > +++ b/net/netfilter/nf_conntrack_proto_tcp.c
> > > @@ -584,8 +584,8 @@ static bool tcp_in_window(const struct nf_conn *ct,
> > >  			 * Let's try to use the data from the packet.
> > >  			 */
> > >  			sender->td_end = end;
> > > -			win <<= sender->td_scale;
> > > -			sender->td_maxwin = (win == 0 ? 1 : win);
> > > +			swin = win << sender->td_scale;
> > > +			sender->td_maxwin = (swin == 0 ? 1 : swin);
> > >  			sender->td_maxend = end + sender->td_maxwin;
> > >  			/*
> > >  			 * We haven't seen traffic in the other direction yet
> > 
> > Jozsef, do you remember if this is intentional?
> 
> No, it's a good spotting.
> 
> Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Applied, thanks.
