From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] Yield in netlink_broadcast when congested
Date: Sun, 17 Oct 2004 15:08:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041017130838.GW21977@postel.suug.ch>
References: <20041017110807.GV21977@postel.suug.ch> <E1CJAMU-0006eR-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@eurodev.net, hadi@cyberus.ca, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1CJAMU-0006eR-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Having 7 listeners in the same process isn't really the killer application
> I was looking for :)

Agreed, my statement was no offense, I'm totally fine with your
path and I think it suits us well.

> > Therefore I guess this is fine for now, the problem might appear again
> > if someone finally writes the netlink daemon to solve the locking
> > problems.
> 
> I don't think I understand what you are referring to.  Could you
> please elaborte?

Although NLM_F_ATOMIC exists it's not a good way to lock certain
sets of netlink requests which must be atomic. Currently there is no
locking implemented in any application as far as i know, f.e. iproute2
looks up an ifindex and uses it w/o locking so the link could
be renamed or removed in between. If we ever implement the ietf
netconf protocol we would also require to provide locking functionality.

For that reason, the idea of a netlink daemon was mentioned a few
times which would act as a gate and implement the required locking
in userspace. This daemon could easly lead to multiple listeners
in a single process. Nevertheless, I guess we can ignore it for now as
it's hypothetical.
