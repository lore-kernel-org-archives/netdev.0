From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: rcu annotation fixup
Date: Wed, 19 Jan 2011 07:18:40 +0200
Message-ID: <20110119051839.GA29467@redhat.com>
References: <20110118110845.GA11555@redhat.com>
 <20110119004040.GE18984@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mel Gorman <mel@csn.ul.ie>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110119004040.GE18984@csn.ul.ie>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 19, 2011 at 12:40:40AM +0000, Mel Gorman wrote:
> On Tue, Jan 18, 2011 at 01:08:45PM +0200, Michael S. Tsirkin wrote:
> > When built with rcu checks enabled, vhost triggers
> > bogus warnings as vhost features are read without
> > dev->mutex sometimes.
> > Fixing it properly is not trivial as vhost.h does not
> > know which lockdep classes it will be used under.
> > Disable the warning by stubbing out the check for now.
> > 
> 
> What is the harm in leaving the bogus warnings until the difficult fix
> happens? RCU checks enabled does not seem like something that is enabled
> in production.

I would like to run with rcu checks enabled sometimes to debug kvm,
which has an elaborate rcu strategy.  Bogus warnings in the log
make it easy to overlook the real ones. Further, the rcu macros
used are a form of documentation. If we have
-               rcu_dereference_index_check(dev->acked_features,
-                                           lockdep_is_held(&dev->mutex));
this means 'taken in rcu read side critical section or under mutex',

+       acked_features = rcu_dereference_index_check(dev->acked_features, 1);
means 'not checked'.

> If this patch is applied, there is always the risk that
> it'll be simply forgotten about.

Well, that's why I put in a TODO.
If there's a demand for that, I can add a Kconfig option to
trigger a warning at each unchecked rcu call in vhost-net
but I doubt it'll get a lof of use :)


> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab
