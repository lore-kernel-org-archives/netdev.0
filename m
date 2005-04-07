From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] RTNETLINK: Protocol family wildcard dumping for routing rules
Date: Fri, 8 Apr 2005 01:24:27 +0200
Message-ID: <20050407232427.GY26731@postel.suug.ch>
References: <20050407213838.GW26731@postel.suug.ch> <E1DJfBR-0007Ym-00@gondolin.me.apana.org.au> <20050407223847.GX26731@postel.suug.ch> <1112915616.1089.27.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112915616.1089.27.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1112915616.1089.27.camel@jzny.localdomain> 2005-04-07 19:13
> On Thu, 2005-04-07 at 18:38, Thomas Graf wrote:
> > -	[RTM_GETNEIGH - RTM_BASE] = { .dumpit = neigh_dump_info	      }
> > +	[RTM_GETNEIGH - RTM_BASE] = { .dumpit = neigh_dump_info	      },
> > +	[RTM_GETRULE  - RTM_BASE] = { .dumpit = rtnetlink_dump_all    },
> >  };
> >  
> 
> Shouldnt this just work (without this change) if you have
> CONFIG_IP_MULTIPLE_TABLES?

Not sure what you mean, it doesn't even get into the routing
code but already fails in rtnetlink_rcv_msg when it doesn't
find a dumpit implementation for family == AF_UNSPEC.

> If you want to be funky and have some default dumper always,
> why not make the change to set dumpit to rtnetlink_dump_all in the code
> when dumpit is found to be NULL as a last resort?

That is exactly what happens, it will first look up the address
family dumpit and if none exist falls back to the rtnetlink_dump_all
introduced above.

	if (link->dumpit == NULL)
		link = &(rtnetlink_links[PF_UNSPEC][type]);

	if (link->dumpit == NULL)
		goto err_inval; /* <-- we used to fail here for PF_UNSPEC */

	if ((*errp = netlink_dump_start(rtnl, skb, nlh, ...
