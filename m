From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] RTNETLINK: Protocol family wildcard dumping for
	routing rules
Date: 07 Apr 2005 20:48:20 -0400
Message-ID: <1112921300.1088.54.camel@jzny.localdomain>
References: <20050407213838.GW26731@postel.suug.ch>
	 <E1DJfBR-0007Ym-00@gondolin.me.apana.org.au>
	 <20050407223847.GX26731@postel.suug.ch>
	 <1112915616.1089.27.camel@jzny.localdomain>
	 <20050407232427.GY26731@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050407232427.GY26731@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-04-07 at 19:24, Thomas Graf wrote:
> * jamal <1112915616.1089.27.camel@jzny.localdomain> 2005-04-07 19:13
> > On Thu, 2005-04-07 at 18:38, Thomas Graf wrote:
> > > -	[RTM_GETNEIGH - RTM_BASE] = { .dumpit = neigh_dump_info	      }
> > > +	[RTM_GETNEIGH - RTM_BASE] = { .dumpit = neigh_dump_info	      },
> > > +	[RTM_GETRULE  - RTM_BASE] = { .dumpit = rtnetlink_dump_all    },
> > >  };
> > >  
> > 
> > Shouldnt this just work (without this change) if you have
> > CONFIG_IP_MULTIPLE_TABLES?
> 
> Not sure what you mean, it doesn't even get into the routing
> code but already fails in rtnetlink_rcv_msg when it doesn't
> find a dumpit implementation for family == AF_UNSPEC.
> 

Right but if CONFIG_IP_MULTIPLE_TABLES is compiled it will find it in 
family = PF_INET, no?
In the minimal shouldnt you have #ifdef CONFIG_IP_MULTIPLE_TABLES around
that defined?

> That is exactly what happens, it will first look up the address
> family dumpit and if none exist falls back to the rtnetlink_dump_all
> introduced above.
> 
> 	if (link->dumpit == NULL)
> 		link = &(rtnetlink_links[PF_UNSPEC][type]);
> 
> 	if (link->dumpit == NULL)
> 		goto err_inval; /* <-- we used to fail here for PF_UNSPEC */
> 
> 	if ((*errp = netlink_dump_start(rtnl, skb, nlh, ...

I mean why dont you just set it there in that last part where it
currently fails? i.e set link->dumpit to rtnetlink_dump_all

cheers,
jamal
