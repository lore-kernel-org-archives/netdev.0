From: "David Miller" <davem@davemloft.net>
Subject: Re: Dropping NETIF_F_SG since no checksum
 feature.
Date: Wed, 11 Oct 2006 13:52:01 -0700 (PDT)
Message-ID: <20061011.135201.15405152.davem@davemloft.net>
References: <20061011090926.GA15393@fogou.chygwyn.com>
 <20061011150103.GF4888@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org,
	steve@chygwyn.com,
	shemminger@osdl.org
Return-path: <openib-general-bounces@openib.org>
To: mst@mellanox.co.il
In-Reply-To: <20061011150103.GF4888@mellanox.co.il>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Date: Wed, 11 Oct 2006 17:01:03 +0200

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

I certainly don't.
