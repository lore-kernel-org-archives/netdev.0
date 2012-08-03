From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 1/7] netpoll: use GFP_ATOMIC in slave_enable_netpoll()
 and __netpoll_setup()
Date: Fri, 03 Aug 2012 17:34:47 +0800
Message-ID: <1343986487.20871.2.camel@cr0>
References: <1343403484-29347-1-git-send-email-amwang@redhat.com>
	 <1343403484-29347-2-git-send-email-amwang@redhat.com>
	 <1343985428.9299.868.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Joe Perches <joe@perches.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1343985428.9299.868.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-08-03 at 11:17 +0200, Eric Dumazet wrote:
> On Fri, 2012-07-27 at 23:37 +0800, Cong Wang wrote:
> > slave_enable_netpoll() and __netpoll_setup() may be called
> > with read_lock() held, so should use GFP_ATOMIC to allocate
> > memory.
> > 
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> > ---
> >  drivers/net/bonding/bond_main.c |    2 +-
> >  net/core/netpoll.c              |    2 +-
> >  2 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> > index 6fae5f3..ab773d4 100644
> > --- a/drivers/net/bonding/bond_main.c
> > +++ b/drivers/net/bonding/bond_main.c
> > @@ -1235,7 +1235,7 @@ static inline int slave_enable_netpoll(struct slave *slave)
> >  	struct netpoll *np;
> >  	int err = 0;
> >  
> > -	np = kzalloc(sizeof(*np), GFP_KERNEL);
> > +	np = kzalloc(sizeof(*np), GFP_ATOMIC);
> >  	err = -ENOMEM;
> >  	if (!np)
> >  		goto out;
> > diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> > index b4c90e4..c78a966 100644
> > --- a/net/core/netpoll.c
> > +++ b/net/core/netpoll.c
> > @@ -734,7 +734,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
> >  	}
> >  
> >  	if (!ndev->npinfo) {
> > -		npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);
> > +		npinfo = kmalloc(sizeof(*npinfo), GFP_ATOMIC);
> >  		if (!npinfo) {
> >  			err = -ENOMEM;
> >  			goto out;
> 
> Yes this works, but maybe you instead could pass/add a gfp_t flags
> argument to __netpoll_setup() ?
> 
> Management tasks should allow GFP_KERNEL allocations to have less
> failure risks.
> 
> Its sad bonding uses the rwlock here instead of a mutex
> 

Yup, that is a good idea. I will update this patch.

Thanks!
