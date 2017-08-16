From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch] netlink.7: srcfix Change buffer size in example code
 about reading netlink message.
Date: Wed, 16 Aug 2017 02:37:50 +0200
Message-ID: <86910c29-c68c-dc7d-d5b9-3f20128d5af1@gmail.com>
References: <e9409957290af5249750afa0f10de3a6@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dwilder <dwilder-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <e9409957290af5249750afa0f10de3a6-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Content-Language: en-US
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/14/2016 11:20 PM, dwilder wrote:
> The example code in netlink(7) (for reading netlink message) suggests 
> using
> a 4k read buffer with recvmsg.  This can cause truncated messages on 
> systems
> using a page size is >4096.  Please see:
> linux/include/linux/netlink.h (in the kernel source)
> 
> <snip>
> /*
>   *      skb should fit one page. This choice is good for headerless 
> malloc.
>   *      But we should limit to 8K so that userspace does not have to
>   *      use enormous buffer sizes on recvmsg() calls just to avoid
>   *      MSG_TRUNC when PAGE_SIZE is very large.
>   */
> #if PAGE_SIZE < 8192UL
> #define NLMSG_GOODSIZE  SKB_WITH_OVERHEAD(PAGE_SIZE)
> #else
> #define NLMSG_GOODSIZE  SKB_WITH_OVERHEAD(8192UL)
> #endif
> 
> #define NLMSG_DEFAULT_SIZE (NLMSG_GOODSIZE - NLMSG_HDRLEN)
> <snip>
> 
> I was troubleshooting some up-stream code on a ppc64le system
> (page:size of 64k) This code had duplicated the example from netlink(7) 
> and
> was using a 4k buffer.  On x86-64 with a 4k page size this is not a 
> problem,
> however on the 64k page system some messages were truncated.  Using an 
> 8k buffer
> as implied in netlink.h prevents problems with any page size.
> 
> Lets change the example so others don't propagate the problem further.
> 
> Signed-off-by David Wilder <dwilder-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Thanks, David. Patch applied.

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
