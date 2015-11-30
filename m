From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH RFC] libnetlink: introduce DECLARE_NLREQ
Date: Mon, 30 Nov 2015 16:47:25 +0100
Message-ID: <20151130154724.GC17712@orbit.nwl.cc>
References: <1448544365-23153-1-git-send-email-phil@nwl.cc>
 <20151129120752.73834f50@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:58436 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752297AbbK3Pr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2015 10:47:26 -0500
Content-Disposition: inline
In-Reply-To: <20151129120752.73834f50@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 29, 2015 at 12:07:52PM -0800, Stephen Hemminger wrote:
> On Thu, 26 Nov 2015 14:26:05 +0100
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > This macro aims to simplify most netlink users' pattern to prepare a
> > request, which is to create an unnamed struct and initialize it:
> > 
> > | struct {
> > |	struct nlmsghdr n;
> > |	struct whatever foo;
> > |	char buf[arbitrary number];
> > | } req;
> > |
> > | memset(&req, 0, sizeof(req));
> > | req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct whatever));
> > | req.n.nlmsg_flags = NLM_F_REQUEST;
> > 
> > Having this patch applied, the above can be replaced by a static
> > initializer like so:
> > 
> > | DECLARE_NLREQ(req, n, struct whatever foo, arbitrary number);
> > 
> > There is an added benefit, as well: Due to explicit alignment, the
> > requested tailroom is really as big as requested no matter what size
> > struct whatever really is.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> > This patch is RFC because I want to wait for peer review and upstream
> > acceptance before sending in the big refactoring patch itself.
> > ---
> >  include/libnetlink.h | 11 +++++++++++
> >  1 file changed, 11 insertions(+)
> 
> I am not a fan of complex macros. But netlink seems to get lots of them.
> You need to add more parens round arguments (like name).
> 
> Really longterm would rather iproute2 switched to a cleaner library like libmnl

libmnl looks nice and simple (unlike libnl I was initially looking at by
accident). Now how to pull this off:

I don't think mandatorily depending on libmnl will be acceptable, do
you? So I can imagine two ways to do this:

A) Have a libmnl version of lib/libnetlink.c which is used instead of
   the old one if libmnl is present.

B) Pull a copy of libmnl into iproute2 sources so it's always available
   (as fallback) and make it replace lib/libnetlink.c. This sounds worse
   than it is, using git-subtree allows to do this without imposing user
   knowledge about it (like git-submodule does).

What do you think?

Cheers, Phil
