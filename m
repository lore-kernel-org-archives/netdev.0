From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] netpoll: Remove unused EXPORT_SYMBOLs of
 netpoll_poll and netpoll_poll_dev
Date: Mon, 04 Jul 2011 00:46:29 -0700
Message-ID: <1309765589.18925.42.camel@Joe-Laptop>
References: <cover.1309482314.git.joe@perches.com>
	 <282ce7d68b97c4dbfb759c1c0752e6cbddfeeafc.1309482314.git.joe@perches.com>
	 <20110704065320.GA2588@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Harry Wei <jiaweiwei.xiyou@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110704065320.GA2588@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-07-04 at 14:53 +0800, Harry Wei wrote:
> On Thu, Jun 30, 2011 at 06:08:57PM -0700, Joe Perches wrote:
> > Unused symbols waste space.
> > Commit 0e34e93177fb
> > "(netpoll: add generic support for bridge and bonding devices)"
> > added the symbol more than a year ago with the promise of "future use".
> > Because it is so far unused, remove it for now.
> > It can be easily readded if or when it actually needs to be used.
> > cc: WANG Cong <amwang@redhat.com>
> > Signed-off-by: Joe Perches <joe@perches.com>
> > ---
> >  include/linux/netpoll.h |    2 --
> >  net/core/netpoll.c      |    6 ++----
> >  2 files changed, 2 insertions(+), 6 deletions(-)
> > diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
[]
> > @@ -40,8 +40,6 @@ struct netpoll_info {
> >  	struct netpoll *netpoll;
> >  };
> >  
> > -void netpoll_poll_dev(struct net_device *dev);
> > -void netpoll_poll(struct netpoll *np);
> >  void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
> >  void netpoll_print_options(struct netpoll *np);
> >  int netpoll_parse_options(struct netpoll *np, char *opt);
> > diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> > index 18d9cbd..4ce595e 100644
> > --- a/net/core/netpoll.c
> > +++ b/net/core/netpoll.c
> > @@ -177,7 +177,7 @@ static void service_arp_queue(struct netpoll_info *npi)
> >  	}
> >  }
> >  
> > -void netpoll_poll_dev(struct net_device *dev)
> > +static void netpoll_poll_dev(struct net_device *dev)
> You have removed the function declaration in include/linux/netpoll.h.

Because it's unused by anything in the tree
but netpoll.c

> And you changed the function like 
> static void netpoll_poll_dev(...)
> {
> 	...
> }
> But i don't know its usage.

It's now a local function to netpoll.c

> The 'static' before this function just says the active area of 'netpoll_poll_dev'
> is in the file net/core/netpoll.c. What is the purpose? Could you please tell me?

It prods the device to perform network work.

	/* Process pending work on NIC */
	ops->ndo_poll_controller(dev);

	poll_napi(dev);
