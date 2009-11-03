From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/3] sysfs directory scaling: rbtree for dirent name
	lookups
Date: Tue, 3 Nov 2009 08:07:15 -0800
Message-ID: <20091103160715.GD23857@kroah.com>
References: <20091101163130.GA7911@kvack.org> <20091103035058.GA19515@kroah.com> <4AEFCA49.4020305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin LaHaise <bcrl@lhnet.ca>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754402AbZKCQKZ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AEFCA49.4020305@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 03, 2009 at 07:14:33AM +0100, Eric Dumazet wrote:
> Greg KH a ?crit :
> > On Sun, Nov 01, 2009 at 11:31:30AM -0500, Benjamin LaHaise wrote:
> >> Use an rbtree in sysfs_dirent to speed up file lookup times
> >>
> >> Systems with large numbers (tens of thousands and more) of network 
> >> interfaces stress the sysfs code in ways that make the linear search for 
> >> a name match take far too long.  Avoid this by using an rbtree.
> > 
> > What kind of speedups are you seeing here?  And do these changes cause a
> > memory increase due to the structure changes which outweigh the
> > speedups?
> > 
> > What kind of test are you doing to reproduce this?
> > 
> 
> Its curious because in my tests the biggest problems come from
> kernel/sysctl.c (__register_sysctl_paths) consuming 80% of cpu
> in following attempt to create 20.000 devices
> 
> (disable hotplug before trying this, and ipv6 too !)
> modprobe dummy numdummies=20000
> 
> I believe we should address __register_sysctl_paths() scalability
> problems too.

But registering 20000 devices is a far different problem from using
those 20000 devices :)

I think the "use the device" path should be the one we care the most
about fixing up, as that is much more common than the register path for
all users.

thanks,

greg k-h
