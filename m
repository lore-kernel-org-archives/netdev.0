From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 7/8] net: Allow setting the network namespace by fd
Date: Fri, 24 Sep 2010 16:09:43 +0200
Message-ID: <20100924140943.GB1551619@jupiter.n2.diac24.net>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
 <m1hbhgq1v1.fsf@fess.ebiederm.org>
 <1285240926.5036.7.camel@bigi>
 <20100923145856.GB1160234@jupiter.n2.diac24.net>
 <1285329084.13976.661.camel@bigi>
 <20100924125704.GA1551619@jupiter.n2.diac24.net>
 <1285335173.13976.693.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1285335173.13976.693.camel@bigi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 24, 2010 at 09:32:53AM -0400, jamal wrote:
> On Fri, 2010-09-24 at 14:57 +0200, David Lamparter wrote:
> > No. While you sure could associate routes with devices, they don't
> > *functionally* reside on top of network devices. They reside on top of
> > the entire IP configuration, 
> 
> I think i am not clearly making my point. There are data dependencies;
> If you were to move routes, youd need everything that routes depend on.
> IOW, if i was to draw a functional graph, routes would appear on top
> of netdevs (I dont care what other functional blocks you put in between
> or sideways to them).

I understood your point. What I'm saying is that that functional graph
you're describing is too simplistic do be a workable model. Your graph
allows for what you're trying to do, yes. But your graph is not modeling
the reality.

> > The routes depend on your BGP view, and
> > if your set of interfaces (and peers) changes, your routes will change.
> > Your bgpd will, either way, need to set up new peerings and redo best
> > path evaluations.
> 
> Worst case scenario, yes. I am beginning to get a feeling we are trying 
> to achieve different goals maybe? Why are you even migrating netdevs?

Err... I'm migrating netdevs to assign them to namespaces to allow them
to use them? Setup, basically. Either way a device move only happens as
result of some administrative action; be it creating a new namespace or
changing the physical/logical network setup.

> > (On an unrelated note, how often are you planning to move stuff between
> > namespaces? I don't expect to be moving stuff except on configuration
> > events...)
> 
> Triggering on config events is useful and it is likely the only
> possibility if you assumed the other namespace is remote.

wtf is a "remote" namespace?

>                                                           But if could
> send a single command to migrate several things in the kernel (in my
> case to recover state to a different ns), then that is much simpler and
> uses the least resources (memory, cpu, bandwidth). I admit it is very
> hard to do in most cases where the underlying dependencies are evolving
> and synchronizing via user space is the best approach. The example
> of route table i pointed to is simple.
> Besides that: dynamic state created in the kernel that doesnt have to be
> recreated by the next arriving 100K packets helps to improve recovery.

Can you please describe your application that requires moving possibly
several network devices together with "their" routes to a different
namespace?


-David
