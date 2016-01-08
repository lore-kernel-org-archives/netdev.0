From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [Linux-v4.4-LTS] ppp: Backport of rtnetlink device handling
Date: Fri, 8 Jan 2016 12:54:35 +0100
Message-ID: <20160108115435.GT18510@alphalink.fr>
References: <CA+icZUXJwvr7k1xrEy1w_Fw4D3V-LA7dKfDa0gxHHmNu3XY=kw@mail.gmail.com>
 <20160104125528.GB1267@alphalink.fr>
 <CA+icZUWrK+jO7PBkvRqHQoNJEDsGgzHnM1fod+zzXdKXWHdHCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Sedat Dilek <sedat.dilek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:49265 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbcAHLyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 06:54:38 -0500
Content-Disposition: inline
In-Reply-To: <CA+icZUWrK+jO7PBkvRqHQoNJEDsGgzHnM1fod+zzXdKXWHdHCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 08, 2016 at 10:28:39AM +0100, Sedat Dilek wrote:
> On Mon, Jan 4, 2016 at 1:55 PM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> > On Mon, Jan 04, 2016 at 08:47:30AM +0100, Sedat Dilek wrote:
> >> Hi Guillaume,
> >>
> >> which patches do I need to backport "ppp: rtnetlink device handling"
> >> to Linux v4.4 which will be a LongTerm-Supported (LTS) Linux-kernel
> >> [0]?
> >>
> > Quite frankly, backporting this series doesn't look like a good idea.
> > It only provides a new ABI for creating ppp devices and your control
> > plane most likely hasn't been updated to use it. So it won't bring any
> > benefit.
> >
> 
> What do you mean by "control plane"?
> 
For the purpose of this discussion, I mean the PPP daemon running in
user space (programs like pppd or accel-ppp).

They implement control protocols like LCP, authentication and various
NCPs, used to negociate PPP encapsulation parameters. They also have to
report on these parameters to the kernel, so that it can properly
handle data exchanged over the established PPP connections. This
generally includes creating a ppp device.

My patch set allows user space to create ppp devices using rtnetlink,
which is more flexible than the current PPP specific ioctl(). But the
PPP daemon needs to be updated or it won't know about the new rtnetlink
and will continue to use the ioctl (which is fine as long as the added
features brought by rtnetlink aren't necessary). That's why I wonder
why do you want to backport this series. I brings no value if user
space isn't able to take advantage of PPP's rtnetlink API.

FYI, the plan is to use the rtnl interface to handle things like
network isolation (with network namespaces) and deterministic ppp
device names in accel-ppp.

> Does anything speak against to have these patches for upcoming Linux v4.5?
> AFAICS, the merge-window will open next week.
> 
The patch set has been deferred due to lack of external reviews. I'll
repost after the merge window, so that interested people will have
enough time to comment on it. Therefore it won't be in v4.5. If
everything goes fine with the new submission, it could go into v4.6.
