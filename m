From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH 1/3] sysfs directory scaling: rbtree for dirent name lookups
Date: Tue, 3 Nov 2009 18:38:47 +0200
Message-ID: <200911031838.47168.opurdila@ixiacom.com>
References: <20091101163130.GA7911@kvack.org> <4AEFCA49.4020305@gmail.com> <20091103160715.GD23857@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>,
	linux-kernel@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752918AbZKCQlm@vger.kernel.org>
In-Reply-To: <20091103160715.GD23857@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 03 November 2009 18:07:15 you wrote:

> > > What kind of test are you doing to reproduce this?
> >
> > Its curious because in my tests the biggest problems come from
> > kernel/sysctl.c (__register_sysctl_paths) consuming 80% of cpu
> > in following attempt to create 20.000 devices
> >
> > (disable hotplug before trying this, and ipv6 too !)
> > modprobe dummy numdummies=20000
> >
> > I believe we should address __register_sysctl_paths() scalability
> > problems too.
> 
> But registering 20000 devices is a far different problem from using
> those 20000 devices :)
> 
> I think the "use the device" path should be the one we care the most
> about fixing up, as that is much more common than the register path for
> all users.
> 

For sysctl in general probably, but I would argue that for dynamic network 
interfaces (ppp and other sorts of tunnels) the "use" and "register" paths are 
not that unbalanced.

For our case where we use up to 128K interfaces, sysctl entries per network 
interface is pretty much unusable - but I agree that is not a very common case 
:) 

However [1] is not so far fetched.

[1] http://www.spinics.net/lists/netdev/msg110392.html

Thanks,
tavi
