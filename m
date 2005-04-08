From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] RTNETLINK: Protocol family wildcard dumping for routing rules
Date: Fri, 8 Apr 2005 03:04:06 +0200
Message-ID: <20050408010406.GZ26731@postel.suug.ch>
References: <20050407213838.GW26731@postel.suug.ch> <E1DJfBR-0007Ym-00@gondolin.me.apana.org.au> <20050407223847.GX26731@postel.suug.ch> <1112915616.1089.27.camel@jzny.localdomain> <20050407232427.GY26731@postel.suug.ch> <1112921300.1088.54.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112921300.1088.54.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1112921300.1088.54.camel@jzny.localdomain> 2005-04-07 20:48
> Right but if CONFIG_IP_MULTIPLE_TABLES is compiled it will find it in 
> family = PF_INET, no?

Yes if rtgenmsg->rtgen_family is set to PF_IPV4. What I'm trying to
achieve is that if the user specifies PF_UNSPEC that it will look
through all families looking for possible rules to dump, ...

> In the minimal shouldnt you have #ifdef CONFIG_IP_MULTIPLE_TABLES around
> that defined?

...  this may include rule systems that do not depend on
CONFIG_IP_MULTIPLE_TABLES, e.g. IPv6 is likely to get an own config option
for this. Or someday we might have DECnet rules? I don't know.

> I mean why dont you just set it there in that last part where it
> currently fails? i.e set link->dumpit to rtnetlink_dump_all

Because that would interefer with the RTM_GETLINK and RTM_GETNEIGH.
We need that link_rtnetlink_table which is then mapped to PF_UNSPEC
and PF_PACKET protocol family for the wildcard support.
