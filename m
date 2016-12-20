From: David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 19 Dec 2016 18:44:10 -0700
Message-ID: <2dbec775-6304-e44c-19c5-fbf07877e7b1@gmail.com>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com>
 <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com>
 <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
        Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/19/16 5:25 PM, Andy Lutomirski wrote:
> net.socket_create_filter = "none": no filter
> net.socket_create_filter = "bpf:baadf00d": bpf filter
> net.socket_create_filter = "disallow": no sockets created period
> net.socket_create_filter = "iptables:foobar": some iptables thingy
> net.socket_create_filter = "nft:blahblahblah": some nft thingy
> net.socket_create_filter = "address_family_list:1,2,3": allow AF 1, 2, and 3

Such a scheme works for the socket create filter b/c it is a very simple use case. It does not work for the ingress and egress which allow generic bpf filters.

...

>> you're ignoring use cases I described earlier.
>> In vrf case there is only one ifindex it needs to bind to.
> 
> I'm totally lost.  Can you explain what this has to do with the cgroup
> hierarchy?

I think the point is that a group hierarchy makes no sense for the VRF use case. What I put into iproute2 is

    cgrp2/vrf/NAME

where NAME is the vrf name. The filter added to it binds ipv4 and ipv6 sockets to a specific device index. cgrp2/vrf is the "default" vrf and does not have a filter. A user can certainly add another layer cgrp2/vrf/NAME/NAME2 but it provides no value since VRF in a VRF does not make sense. 

...

>>> I like this last one, but IT'S NOT A POSSIBLE FUTURE EXTENSION.  You
>>> have to do it now (or disable the feature for 4.10).  This is why I'm
>>> bringing this whole thing up now.
>>
>> We don't have to touch user visible api here, so extensions are fine.
> 
> Huh?  My example in the original email attaches a program in a
> sub-hierarchy.  Are you saying that 4.11 could make that example stop
> working?

Are you suggesting sub-cgroups should not be allowed to override the filter of a parent cgroup?
