From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC:kvm] export host NUMA info to guest & make
 emulated device NUMA attr
Date: Wed, 23 May 2012 18:16:05 +0300
Message-ID: <20120523151604.GB30542@redhat.com>
References: <1337246456-30909-1-git-send-email-kernelfans@gmail.com>
	<1337357675.12999.31.camel@oc3660625478.ibm.com>
	<CAFgQCTsdXqitVGKm5jQjtC--yvZy6x04zRduJ+_tXqUnkncdog@mail.gmail.com>
	<4FBCF99F.4070409@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar <krkumar2@in.ibm.com>, Rusty Russell <rusty@rustcorp.com.au>,
	Shirley Ma <xma@us.ibm.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, Shirley Ma <mashirle@us.ibm.com>,
	qemu-devel@nongnu.org, Liu ping fan <kernelfans@gmail.com>,
	linux-kernel@vger.kernel.org, Tom Lendacky <toml@us.ibm.com>,
	Ryan Harper <ryanh@us.ibm.com>, Avi Kivity <avi@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
To: Andrew Theurer <habanero@linux.vnet.ibm.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
Content-Disposition: inline
In-Reply-To: <4FBCF99F.4070409@linux.vnet.ibm.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On Wed, May 23, 2012 at 09:52:15AM -0500, Andrew Theurer wrote:
> On 05/22/2012 04:28 AM, Liu ping fan wrote:
> >On Sat, May 19, 2012 at 12:14 AM, Shirley Ma<mashirle@us.ibm.com>  wrote:
> >>On Thu, 2012-05-17 at 17:20 +0800, Liu Ping Fan wrote:
> >>>Currently, the guest can not know the NUMA info of the vcpu, which
> >>>will
> >>>result in performance drawback.
> >>>
> >>>This is the discovered and experiment by
> >>>         Shirley Ma<xma@us.ibm.com>
> >>>         Krishna Kumar<krkumar2@in.ibm.com>
> >>>         Tom Lendacky<toml@us.ibm.com>
> >>>Refer to -
> >>>http://www.mail-archive.com/kvm@vger.kernel.org/msg69868.html
> >>>we can see the big perfermance gap between NUMA aware and unaware.
> >>>
> >>>Enlightened by their discovery, I think, we can do more work -- that
> >>>is to
> >>>export NUMA info of host to guest.
> >>
> >>There three problems we've found:
> >>
> >>1. KVM doesn't support NUMA load balancer. Even there are no other
> >>workloads in the system, and the number of vcpus on the guest is smaller
> >>than the number of cpus per node, the vcpus could be scheduled on
> >>different nodes.
> >>
> >>Someone is working on in-kernel solution. Andrew Theurer has a working
> >>user-space NUMA aware VM balancer, it requires libvirt and cgroups
> >>(which is default for RHEL6 systems).
> >>
> >Interesting, and I found that "sched/numa: Introduce
> >sys_numa_{t,m}bind()" committed by Peter and Ingo may help.
> >But I think from the guest view, it can not tell whether the two vcpus
> >are on the same host node. For example,
> >vcpu-a in node-A is not vcpu-b in node-B, the guest lb will be more
> >expensive if it pull_task from vcpu-a and
> >choose vcpu-b to push.  And my idea is to export such info to guest,
> >still working on it.
> 
> The long term solution is to two-fold:
> 1) Guests that are quite large (in that they cannot fit in a host
> NUMA node) must have static mulit-node NUMA topology implemented by
> Qemu. That is here today, but we do not do it automatically, which
> is probably going to be a VM management responsibility.
> 2) Host scheduler and NUMA code must be enhanced to get better
> placement of Qemu memory and threads.  For single-node vNUMA guests,
> this is easy, put it all in one node.  For mulit-node vNUMA guests,
> the host must understand that some Qemu memory belongs with certain
> vCPU threads (which make up one of the guests vNUMA nodes), and then
> place that memory/threads in a specific host node (and continue for
> other memory/threads for each Qemu vNUMA node).

And for IO, we need multiqueue devices such that each
node can have its own queue in its local memory.

-- 
MST
