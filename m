From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 1/1] fair.c: Add/Export find_idlest_perfer_cpu API
Date: Mon, 20 Aug 2012 15:17:21 -0700
Message-ID: <1345501041.6378.10.camel@oc3660625478.ibm.com>
References: <1345232770.16533.234.camel@oc3660625478.ibm.com>
	 <1345464035.23018.38.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	sri@us.ibm.com, vivek@us.ibm.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345464035.23018.38.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-08-20 at 14:00 +0200, Peter Zijlstra wrote:
> On Fri, 2012-08-17 at 12:46 -0700, Shirley Ma wrote:
> > Add/Export a new API for per-cpu thread model networking device
> driver
> > to choose a preferred idlest cpu within allowed cpumask.
> > 
> > The receiving CPUs of a networking device are not under cgroup
> controls.
> > Normally the receiving work will be scheduled on the cpu on which
> the
> > interrupts are received. When such a networking device uses per-cpu
> > thread model, the cpu which is chose to process the packets might
> not be
> > part of cgroup cpusets without using such an API here. 
> > 
> > On NUMA system, by using the preferred cpumask from the same NUMA
> node
> > would help to reduce expensive cross memory access to/from the other
> > NUMA node.
> > 
> > KVM per-cpu vhost will be the first one to use this API. Any other
> > device driver which uses per-cpu thread model and has cgroup cpuset
> > control will use this API later.
> 
> How often will this be called and how do you obtain the cpumasks
> provided to the function? 

It depends. It might be called pretty often if the user keeps changing
cgroups control cpuset. It might be less called if the cgroups control
cpuset is stable, and the host scheduler always schedules the work on
the same NUMA node.

The preferred cpumasks are obtained from local numa node. The allowed
cpumasks are obtained from caller's task allowed cpumasks (cgroups
control cpuset).

Thanks
Shirley
