From: Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Thu, 24 Apr 2014 20:29:41 -0400
Message-ID: <1398385781.2628.452.camel@willson.li.ssimo.org>
References: <20140424203427.GC19091@redhat.com>
	 <20140424.164820.1543648508330465096.davem@davemloft.net>
	 <20140424210429.GD19091@redhat.com>
	 <20140424.171155.806959282091051918.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140424.171155.806959282091051918.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-04-24 at 17:11 -0400, David Miller wrote:
> From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date: Thu, 24 Apr 2014 17:04:29 -0400
> 
> > Does it really matter.
> 
> Good question, if it doesn't matter, you might as well log garbage.
> 
> There are a lot of logical holes in this discussion.
> 
> Real UIDs are always reported at sendmsg() time, not effective ones
> (the UID "at sendmsg() time").
> 
> Therefore if we were to add CGROUP passing at sendmsg() time it should
> report the "real cgroup", the one the task has at the time the file
> descriptor / socket was "created".

Given we are creating a new interface ... should we just send both the
cgroup at creation time and (optionally, if it differs) the cgroup the
process has at sendmsg() time, and let the peer sort out which one it is
interested in ?

Simo.
