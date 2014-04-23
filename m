From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] net: Implement SO_PEERCGROUP and SO_PASSCGROUP
 socket options
Date: Wed, 23 Apr 2014 12:16:21 -0400
Message-ID: <20140423161621.GC24651@redhat.com>
References: <1397596546-10153-1-git-send-email-vgoyal@redhat.com>
 <20140422.160558.627080587952506099.davem@davemloft.net>
 <20140423155512.GA24651@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org,
	dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140423155512.GA24651-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 23, 2014 at 11:55:12AM -0400, Vivek Goyal wrote:
> On Tue, Apr 22, 2014 at 04:05:58PM -0400, David Miller wrote:
> > From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > Date: Tue, 15 Apr 2014 17:15:44 -0400
> > 
> > > This is another version of patchset to add support passing cgroup
> > > information of client over unix socket API.
> > 
> > I'm marking this patch series as "changes requested" in patchwork
> > because if we still end up adding this feature SO_PASSCGROUP needs to
> > be changed to behave like SO_PASSCRED.
> 
> Does this concern of passing of real uid apply to cgroups also. Even
> if somebody tricks suid program to write to fd setup by under priviliged
> program how would that pgram force setuid program to change cgroup.
> 
> To me passing cgroup information looks more like "pid" information where
> we pass the actual pid of setuid program and not the pid of parent who
> setup fd.
> 
> How would one trick setuid program change cgroup? If not, then this class
> of attack does not seem to apply to SO_PASSCGROUP.
> 
> So I think real discussion here should be how "cgroup" information should
> be used and not necessarily whether we should be passing cgroup
> information of sender. This information is already available. One can
> do SO_PASSCRED, get pid, get /proc/pid/cgroup and use cgroup in whatever
> way they want.

Kernel uses cgroup information to provide service differentiation. So lets
say hypothetically I write a logging program which gets the cgroup of
clinent and uses that information to limit the log file size. Is that
a problem?

First of all I am not aware how would I force setuid program to change
cgroup. So even if one tricks setuid program to effectively convert it
into "suid cat", cgroup information remains the same and there is no
privilige escalation here.

And one example Andy had mentioned that what if I pass fd to a service
which accepts fd and it is running in a cgroup. Then we have a problem
at kernel level also. What if that fd is a regular file and that service
it outputting tons of data. Kernel will apply all resource management
rules based one cgroup of *priviliged service* and not based on
caller's cgroup who passed the fd to priviliged service. 

So to me passing cgroup information around at run time and use that
information for resource management in user space will very much
be in line with what kernel is doing and will be no different.

Thanks
Vivek
