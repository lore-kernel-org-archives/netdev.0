From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: Commit 1fe8e0... (include more headers in if_tunnel.h) breaks my
 user-space build.
Date: Sat, 14 Jan 2017 08:43:52 +0200
Message-ID: <20170114064352.GJ8672@lakka.kapsi.fi>
References: <f1cede01-3fa4-130a-fa2d-7cbdfe3648b3@candelatech.com>
 <20170113114158.6e5c3461@xeon-e3>
 <6c983e7e-dbb3-3542-ffed-95f4d2f3c5bc@candelatech.com>
 <20170113140806.01f65b8a@xeon-e3>
 <7f212e93-e9e7-d2aa-2e2d-b36bca8d2f6e@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:43838 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751076AbdANGnz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 14 Jan 2017 01:43:55 -0500
Content-Disposition: inline
In-Reply-To: <7f212e93-e9e7-d2aa-2e2d-b36bca8d2f6e@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 02:11:41PM -0800, Ben Greear wrote:
> On 01/13/2017 02:08 PM, Stephen Hemminger wrote:
> >On Fri, 13 Jan 2017 11:50:32 -0800
> >Ben Greear <greearb@candelatech.com> wrote:
> >
> >>On 01/13/2017 11:41 AM, Stephen Hemminger wrote:
> >>>On Fri, 13 Jan 2017 11:12:32 -0800
> >>>Ben Greear <greearb@candelatech.com> wrote:
> >>>
> >>>>I am including netinet/ip.h, and also linux/if_tunnel.h, and the linux/ip.h conflicts with
> >>>>netinet/ip.h.
> >>>>
> >>>>Maybe my build environment is screwed up, but maybe also it would be better to
> >>>>just let the user include appropriate headers before including if_tunnel.h
> >>>>and revert this patch?
> >>>>
> >>>>
> >>>>include/uapi/linux/if_tunnel.h: include linux/if.h, linux/ip.h and linux/in6.h
> >>>>
> >>>>     Fixes userspace compilation errors like:
> >>>>
> >>>>     error: field ‘iph’ has incomplete type
> >>>>     error: field ‘prefix’ has incomplete type
> >>>>
> >>>>     Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
> >>>>     Signed-off-by: David S. Miller <davem@davemloft.net>
> >>>>
> >>>>Thanks,
> >>>>Ben
> >>>>
> >>>
> >>>What I ended up doing for iproute2 was including all headers used by the source
> >>>based on sanitized kernel headers.  Basically
> >>>  $ git grep '^#include <linux/' | \
> >>>	awk -F: '{print $2}' | \
> >>>	sed -e 's/^#include <//' -e 's/>.*$//' | \
> >>>	sort -u >linux.headers
> >>>   $ for f in $(cat linux.headers)
> >>>     do cp ~/kernel/net-next/usr/include/$f include/$f
> >>>     done
> >>>
> >>>You can't take only some of the headers, once you decide to diverge from glibc provided
> >>>headers, you got to take them all.
> >>>
> >>
> >>I do grab a copy of the linux kernel headers and compile against that, but netinet/ip.h is
> >>coming from the OS.  Do you mean I should not include netinet/ip.h and instead use linux/ip.h?
> >
> >I don't think you can mix netinet/ip.h and linux/ip.h, yes that is a mess.
> >
> 
> Well, I still like the idea of reverting this patch..that way user-space does not have to use
> linux/ip.h, and that lets them use netinet/ip.h and if_tunnel.h.

I might have patches for glibc compat for your case in
https://github.com/mcfrisk/linux/commits/headers_test_v06
if you include glibc headers first and then kernel uapi ones.

> Anyway, I'll let Dave and/or the original committer decide....I've reverted it in my local tree
> so I am able to build again...

My changes make uapi headers compile as they are in userspace. That exposes
problems like this for which user space has had workarounds for decades.
Sorry for that. The glibc compat fixes should help.

-Mikko

> Thanks,
> Ben
> 
> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
> 
