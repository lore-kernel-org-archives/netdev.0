From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH nf-next] netfilter: xtables: lightweight process control
 group matching
Date: Mon, 7 Oct 2013 12:46:47 -0400
Message-ID: <20131007164647.GA2481@htj.dyndns.org>
References: <1380910855-12325-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, cgroups@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1380910855-12325-1-git-send-email-dborkman@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Fri, Oct 04, 2013 at 08:20:55PM +0200, Daniel Borkmann wrote:
> It would be useful e.g. in a server or desktop environment to have
> a facility in the notion of fine-grained "per application" or "per
> application group" firewall policies. Probably, users in the mobile/
> embedded area (e.g. Android based) with different security policy
> requirements for application groups could have great benefit from
> that as well. For example, with a little bit of configuration effort,
> an admin could whitelist well-known applications, and thus block
> otherwise unwanted "hard-to-track" applications like [1] from a
> user's machine.
> 
> Implementation of PID-based matching would not be appropriate
> as they frequently change, and child tracking would make that
> even more complex and ugly. Cgroups would be a perfect candidate
> for accomplishing that as they associate a set of tasks with a
> set of parameters for one or more subsystems, in our case the
> netfilter subsystem, which, of course, can be combined with other
> cgroup subsystems into something more complex.
> 
> As mentioned, to overcome this constraint, such processes could
> be placed into one or multiple cgroups where different fine-grained
> rules can be defined depending on the application scenario, while
> e.g. everything else that is not part of that could be dropped (or
> vice versa), thus making life harder for unwanted processes to
> communicate to the outside world. So, we make use of cgroups here
> to track jobs and limit their resources in terms of iptables
> policies; in other words, limiting what they are allowed to
> communicate.
> 
> We have similar cgroup facilities in networking for traffic
> classifier, and netprio cgroups. This feature adds a lightweight
> cgroup id matching in terms of network security resp. network
> traffic isolation as part of netfilter's xtables subsystem.

I don't think the two net cgroups were a good idea and definitely
don't want to continue the trend.  I think this is being done
backwards.  Wouldn't it be more logical to implement netfilter rule to
match the target cgroup paths?  It really doesn't make much sense to
me to add separate controllers to just tag processes.  Please classify
tasks in cgroup and let netfilter match the cgroups.

Thanks.

-- 
tejun
