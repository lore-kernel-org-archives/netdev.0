From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC PATCH net-next] net: Add l3mdev cgroup
Date: Mon, 4 Jan 2016 12:58:36 -0500
Message-ID: <20160104175836.GA11668@mtj.duckdns.org>
References: <1451925136-13327-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	shm-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org
To: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1451925136-13327-1-git-send-email-dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello, David.

On Mon, Jan 04, 2016 at 08:32:16AM -0800, David Ahern wrote:
> Add cgroup to assoicate tasks with L3 networking domains. AF_INET{6}
> sockets opened by tasks associated with an l3mdev cgroup are bound to
> the associated master device when the socket is created. This allows a
> user to run a command (and its children) within an L3 networking context.
> 
> The master-device for an l3mdev cgroup must be an L3 master device
> (e.g., VRF), and it must be set before attaching tasks to the cgroup. Once
> set the master-device can not change. Nested l3mdev cgroups are not
> supported. The root (aka default) l3mdev cgroup can not be bound to a
> master device.
> 
> Example:
>     ip link add vrf-red type vrf table vrf-red
>     ip link set dev vrf-red up
>     ip link set dev eth1 master vrf-red
> 
>     cgcreate -g l3mdev:vrf-red
>     cgset -r l3mdev.master-device=vrf-red vrf-red
>     cgexec -g l3mdev:vrf-red bash

Please don't create any new controller whose sole purpose is
identifying group membership.  Please take a look at how libxt_cgroup
handles identification w/o creating a new controller.

 http://lkml.kernel.org/g/1449527935-27056-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org

Thanks.

-- 
tejun
