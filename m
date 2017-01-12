From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [net] net/mlx5e: fix another -Wmaybe-uninitialized warning
Date: Thu, 12 Jan 2017 11:10:32 +0100
Message-ID: <3829004.7hNWuNXvZt@wuerfel>
References: <20170111211451.2705705-1-arnd@arndb.de> <5cc9060f-6802-8634-f144-4637e9576ef1@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5cc9060f-6802-8634-f144-4637e9576ef1@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, January 12, 2017 10:30:24 AM CET Or Gerlitz wrote:
> On 1/11/2017 11:14 PM, Arnd Bergmann wrote:
> > @@ -666,14 +666,15 @@ static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
> >       struct rtable *rt;
> >       struct neighbour *n = NULL;
> >       int ttl;
> > +     int ret;
> > +
> > +     if (!IS_ENABLED(CONFIG_INET))
> > +             return -EOPNOTSUPP;
> >   
> > -#if IS_ENABLED(CONFIG_INET)
> >       rt = ip_route_output_key(dev_net(mirred_dev), fl4);
> > -     if (IS_ERR(rt))
> > -             return PTR_ERR(rt);
> > -#else
> > -     return -EOPNOTSUPP;
> > -#endif
> > +     ret = PTR_ERR_OR_ZERO(rt);
> > +     if (ret)
> > +             return ret;
> 
> but this means that if we got NULL from ip_route_output_key, we will 
> return success (0) here which is wrong.

I don't think so: if 'rt' is NULL or a valid pointer, then 'ret' is zero
and we will not return here.

	Arnd
