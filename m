From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: Re: [PATCH] uapi: fix linux/if_pppol2tp.h userspace compilation errors
Date: Tue, 14 Feb 2017 23:29:50 +0300
Message-ID: <20170214202950.GB17325@altlinux.org>
References: <20170214103353.GA8394@altlinux.org> <20170214.143723.629330014459224649.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?utf-8?Q?Asbj=C3=B8rn_Sloth_T=C3=B8nnesen?= <asbjorn@asbjorn.st>,
        jchapman@katalix.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vmicros1.altlinux.org ([194.107.17.57]:54510 "EHLO
        vmicros1.altlinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753943AbdBNU3x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 15:29:53 -0500
Content-Disposition: inline
In-Reply-To: <20170214.143723.629330014459224649.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2017 at 02:37:23PM -0500, David Miller wrote:
> From: "Dmitry V. Levin" <ldv@altlinux.org>
> Date: Tue, 14 Feb 2017 13:33:53 +0300
> 
> > In file included from /usr/include/linux/l2tp.h:12:0,
> >                  from /usr/include/linux/if_pppol2tp.h:21,
> > /usr/include/netinet/in.h:31:8: error: redefinition of 'struct in_addr'
> 
> This is protected properly by __UAPI_DEF_IN_ADDR, so whichever gets
> included first makes the definition.
> 
> This whole thing is designed so that if GLIBC headers are included
> first, __UAPI_DEF_IN_ADDR will be defined to zero, therefore
> linux/in.h won't try to make the definition.  Otherwise it will.
> 
> The facility should not be so fragile that we have to play all
> kinds of header ordering games.  We would be imposing the same
> strange rules on userspace applications including these headers
> which is completely unacceptable.

The facility is so fragile that netinet/in.h cannot be included after
linux/in.h:

$ gcc -S -o/dev/null -xc /dev/null -include /usr/include/linux/in.h -include /usr/include/netinet/in.h
In file included from <command-line>:32:0:
/usr/include/netinet/in.h:31:8: error: redefinition of 'struct in_addr'
 struct in_addr
        ^~~~~~~
In file included from <command-line>:32:0:
/usr/include/linux/in.h:84:8: note: originally defined here
 struct in_addr {
        ^~~~~~~

> So if the facility isn't working correctly, let's fix that instead
> of fidgeting with include ordering all over the tree.

I don't mind if the whole facility will get fixed someday.
My humble objective was just to fix the regression introduced in v4.10-rc1
by commit 47c3e7783be4.


-- 
ldv
