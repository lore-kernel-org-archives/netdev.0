From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] xfrm: add x86 CONFIG_COMPAT support
Date: Wed, 07 Apr 2010 03:08:50 -0700 (PDT)
Message-ID: <20100407.030850.04450543.davem@davemloft.net>
References: <1270506431-25578-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34561
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757067Ab0DGKIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 06:08:48 -0400
In-Reply-To: <1270506431-25578-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue,  6 Apr 2010 00:27:07 +0200

> This has the consequence that compat support is restricted to
> applications that use sendmsg() to talk to the kernel (e.g. iproute2
> would work); because write() will not go through the socket compat
> layer (and thus, the MSG_CMSG_COMPAT won't be set on messages sent
> by means of write() ).
> 
> I sent a patch that solved this by adding a sys_compat_write syscall
> and a ->compat_aio_write() to struct file_operations to the
> vfs mailing list, but that patch was ignored by the vfs people,
> and the x86 folks did not exactly like the idea either.
> 
> So this leaves three alternatives:
> 1 - drop the whole idea and keep the current status.
> 2 - Add new structure definitions (with new numbering) that would work
>     everywhere, keep the old ones for backwards compatibility (This
>     was suggested by Arnd Bergmann).
> 3 - apply this patch set and tell userspace to move the sendmsg() when
>     they want to work with xfrm on x86_64 with 32 bit userland.
> 
> Other than that, I am out of ideas.

So do we know of any xfrm netlink apps that do not use sendmsg()?

I doubt there are any, and if that's true for the most part, then
option #3 seems the best.

We simply can't ignore all of the 32-bit xfrm netlink app binaries out
there and pretend they don't exist.  So #2 doesn't make any sense to
me at all.

And #1, not trying to make it work at all, to me is just as bad
as #2.

If we find a non-trivial number of apps using plain write() then
we might have to consider championing your vfs patch to the
lkml and vfs folks again.  I'll help if this is needed.

Please do some quick research on xfrm netlink sendmsg() vs.
write() usage and based upon your findings we'll act.

Thanks for keeping this work alive.
