From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc 4/4] igb: expose 82576 bandiwidth allocation
Date: Fri, 6 Nov 2009 10:30:37 +1100
Message-ID: <20091105233034.GA9588@verge.net.au>
References: <20091105005847.941190065@vergenet.net>
	<20091105010628.148945886@vergenet.net>
	<4AF358F2.9000109@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arnd Bergmann <arndbergmann@googlemail.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <4AF358F2.9000109@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, Nov 05, 2009 at 03:00:02PM -0800, Alexander Duyck wrote:
> Simon Horman wrote:
> >The 82576 has support for bandwidth allocation to VFs.
> >
> >Contrary to the documentation in the 82576 datasheet v2.41 this
> >appears to work as follows:
> >
> >* The ratio supplied is always proportional to 1Gbit/s,
> >  regardless of if the link speed.
> >* The ratio supplied is an upper-bound on bandwidth available
> >  to the VF, not a minimun guarantee
> >
> >This patch exposes bandwidth control to userspace through a simple
> >per-device (PF) sysfs file, bandwidth_allocation.
> >
> >* The file contains a whitespace delimited list of values, one per VF.
> >* The first value corresponds to the first VF and so on.
> >* Valid values are integers from 0 to 1000
> >* A value of 0 indicates that bandwidth_allocation is disabled.
> >* Other values indicate the allocated bandwidth, in 1/1000ths of a gigabit/s
> >
> >e.g. The following for a PF with 4 VFs allocates ~20Mbits/ to VF 1,
> >     ~100Mbit/s to VF 2, and leave the other 2 VFs with no allocation.
> >
> >     echo "20 100 0 0" > /sys/class/net/eth3/device/bandwidth_allocation
> >
> >This interface is intended to allow testing of the hardware feature.
> >There are ongoing discussions about how to expose this feature
> >to user-space in a more generic way.
> >
> >Signed-off-by: Simon Horman <horms@verge.net.au>
> >
> 
> Of the patches it looks like the only one that really has any issues
> is this one and it is mostly due to the sysfs implementation.  The
> others I would say can be applied and pushed up into the
> net-next-2.6 tree.

Thanks, I suspected as much.

> We're currently working on an iproute2 based solution for
> configuring VFs and can incorporate this functionality into it at
> some point in the future.

Do you have any pointers to discussions relating to that interface.
Do you think it would be worth putting in the sysfs interface in the
mean-time, or would you rather wait?

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
