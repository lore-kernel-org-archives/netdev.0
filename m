From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: Dropping NETIF_F_SG since no checksum
 feature.
Date: Wed, 11 Oct 2006 23:11:53 +0200
Message-ID: <20061011211153.GE15468@mellanox.co.il>
References: <20061011.135201.15405152.davem@davemloft.net>
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
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061011.135201.15405152.davem@davemloft.net>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Quoting r. David Miller <davem@davemloft.net>:
> Subject: Re: Dropping NETIF_F_SG since no checksum feature.
> 
> From: "Michael S. Tsirkin" <mst@mellanox.co.il>
> Date: Wed, 11 Oct 2006 17:01:03 +0200
> 
> > Quoting Steven Whitehouse <steve@chygwyn.com>:
> > > > ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
> > > >                      size_t size, int flags)
> > > > {
> > > >         ssize_t res;
> > > >         struct sock *sk = sock->sk;
> > > > 
> > > >         if (!(sk->sk_route_caps & NETIF_F_SG) ||
> > > >             !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
> > > >                 return sock_no_sendpage(sock, page, offset, size, flags);
> > > > 
> > > > 
> > > > So, it seems that if I set NETIF_F_SG but clear NETIF_F_ALL_CSUM,
> > > > data will be copied over rather than sent directly.
> > > > So why does dev.c have to force set NETIF_F_SG to off then?
> > > >
> > > I agree with that analysis,
> > 
> > So, would you Ack something like the following then?
> 
> I certainly don't.
> 

Dave, sorry, you lost me.
Would a new flag NETIF_F_SW_CSUM be better, to tell network core that device
computes checksums in software, so we should piggyback the checksum
computation with the copy process if possible?

Or is there some other issue?

-- 
MST
