From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: [PATCH] Prefix List against 2.5.70 (re-done)
Date: Thu, 10 Jul 2003 15:16:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0DE5B9.20702@us.ibm.com>
References: <20030627.144752.78715628.davem@redhat.com>	<20030628.130602.63704890.yoshfuji@linux-ipv6.org>	<3F008771.5030206@us.ibm.com> <20030702.091825.72842784.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030702.091825.72842784.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> You do not explain why we (or kernel) NEED(s) this.
> It is not so important how SMALL it is
> though it may cause problems how LARGE it is.

I had explained the reasons for having prefix list i/f in my previous mail. To recap :
-  User don't need to know what the definition of a prefix is, all he has to do is ask
    the kernel and get the list. Otherwise different user apps will have to know the
    definition of a prefix and parse the entry themselves. The parsing is non-trivial (eg
    the address should not LL or MC, there should be no nexthop and it should be added via
    an RA, etc).
-  The kernel code to get the prefix list is small, the top level inet6_dump_fib uses
    either the dump_node or the dump_prefix, the latter being the new user interface. Having
    a user interface makes it easier to get the prefix list without significant bloat to the
    kernel.

> This is design issue; how we should provide L3 per-interface 
> information to userspace; eg. in_device and/or inet6_dev things 
> including per-interface statistics.
> 
> Since I think it is not appropriate to provide per-interface 
> statistics via RTM_xxxROUTE, so I don't agree to provide 
> the RA infomation (i.e. Manage/Otherconf Flags) via 
> RTM_xxxROUTE.
> 
> Options:
>  - use RTM_xxxLINK for L3 operation
>  - introduce RTM_xxxIFACE for L3 per-interface operations

Yes, there are a couple of different ways to do this. One is as you have suggested, but there
is a problem with it. The existing RTM_GETLINK interface returns very generic elements of the
dev (mtu, hardware address, dev statistics), while the change you suggested is specific to
ipv6. I am not sure if this is a good design to implement. Either we could use the current
(submitted) way or use a different RTM_GETADDR interface in inet6_fill_ifaddr (and introduce
RTM_IFACEFLAGS). This will be specific to IPv6. Are you agreeable to this ?

> Well, on moving forward; you can split your patch up to 3 things:
>   1. fix routing flags
>   2. provide Managed/Otherconf flags API
>  (3. provide the prefix list API (if it IS required))
> 
> I'm not against the first item.
> We need to discuss on the design related to the 2nd item.
> I don't think that we really need 3rd item.

- I am ok with 1 :-)
- I have suggested changes for 2, please let me know what you think, whether we can go with the
   old way or make the change suggested above.
- I believe we need #3 for the reasons given above.

Thanks,

- KK
