From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Thu, 13 Mar 2014 11:00:34 -0400
Message-ID: <20140313150034.GG18914@redhat.com>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
 <1394657163-7472-3-git-send-email-vgoyal@redhat.com>
 <5320CAEC.6030008@amacapital.net>
 <CALCETrUTjN=XKwnO62P9roZtLLuk7_9Oi17Mj_Aa2ZFtZc1gVA@mail.gmail.com>
 <20140313141422.GB18914@redhat.com>
 <1394722534.32465.227.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1394722534.32465.227.camel-Hs+ccMQdwurzDu64bZtGtWD2FQJk+8+b@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 13, 2014 at 10:55:34AM -0400, Simo Sorce wrote:

[..]
> > > This might not be quite as awful as I thought.  At least you're
> > > looking up the cgroup at connection time instead of at send time.
> > > 
> > > OTOH, this is still racy -- the socket could easily outlive the cgroup
> > > that created it.
> > 
> > That's a good point. What guarantees that previous cgroup was not
> > reassigned to a different container.
> > 
> > What if a process A opens the connection with sssd. Process A passes the
> > file descriptor to a different process B in a differnt container.
> 
> Stop right here.
> If the process passes the fd it is not my problem anymore.
> The process can as well just 'proxy' all the information to another
> process.
> 
> We just care to properly identify the 'original' container, we are not
> in the business of detecting malicious behavior. That's something other
> mechanism need to protect against (SELinux or other LSMs, normal
> permissions, capabilities, etc...).
> 
> > Process A exits. Container gets removed from system and new one gets
> > launched which uses same cgroup as old one. Now process B sends a new
> > request and SSSD will serve it based on policy of newly launched
> > container.
> > 
> > This sounds very similar to pid race where socket/connection will outlive
> > the pid.
> 
> Nope, completely different.
> 

I think you missed my point. Passing file descriptor is not the problem.
Problem is reuse of same cgroup name for a different container while
socket lives on. And it is same race as reuse of a pid for a different
process.

Thanks
Vivek
