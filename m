From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Wed, 11 Oct 2006 21:11:38 +0100
Message-ID: <20061011201138.GA21657@fogou.chygwyn.com>
References: <20061011090926.GA15393@fogou.chygwyn.com> <20061011150103.GF4888@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	openib-general@openib.org, rolandd@cisco.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161228AbWJKURw@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Content-Disposition: inline
In-Reply-To: <20061011150103.GF4888@mellanox.co.il>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Oct 11, 2006 at 05:01:03PM +0200, Michael S. Tsirkin wrote:
> Quoting Steven Whitehouse <steve@chygwyn.com>:
> > > ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
> > >                      size_t size, int flags)
> > > {
> > >         ssize_t res;
> > >         struct sock *sk = sock->sk;
> > > 
> > >         if (!(sk->sk_route_caps & NETIF_F_SG) ||
> > >             !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
> > >                 return sock_no_sendpage(sock, page, offset, size, flags);
> > > 
> > > 
> > > So, it seems that if I set NETIF_F_SG but clear NETIF_F_ALL_CSUM,
> > > data will be copied over rather than sent directly.
> > > So why does dev.c have to force set NETIF_F_SG to off then?
> > >
> > I agree with that analysis,
> 
> So, would you Ack something like the following then?
>

In so far as I'm able to ack it, then yes, but with the following
caveats: that you also need to look at the tcp code's checks for
NETIF_F_SG (aside from the interface to tcp_sendpage which I think
we've agreed is ok) and ensure that this patch will not change their
behaviour, and here I'm thinking of the test in net/ipv4/tcp.c:select_size()
in particular - there may be others but thats the only one I can think
of off the top of my head. I think this is what davem was getting at
with his comment about copy & sum for smaller packets.

Also all subject to approval by davem and shemminger of course :-)

My general feeling is that devices should advertise the features that
they actually have and that the protocols should make the decision
as to which ones to use or not depending on the combinations available
(which I think is pretty much your argument).

Steve.
