From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: iproute2 (addr flush) infinite loop when unprivileged users
Date: Sat, 26 Jan 2008 11:11:06 -0800
Message-ID: <20080126111106.094c9f4e@deepthought>
References: <9e0cf0bf0801251500u388b9a5dxda92d6d1e3d86233@mail.gmail.com>
	<20080125161259.0356c990@deepthought>
	<9e0cf0bf0801251622w203c515fn80cba5f233bd599d@mail.gmail.com>
	<9e0cf0bf0801260058s797d2ea3r7af013d0957554d8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Alon Bar-Lev" <alon.barlev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41225 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754519AbYAZTLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2008 14:11:20 -0500
In-Reply-To: <9e0cf0bf0801260058s797d2ea3r7af013d0957554d8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 26 Jan 2008 10:58:58 +0200
"Alon Bar-Lev" <alon.barlev@gmail.com> wrote:

> On 1/26/08, Alon Bar-Lev <alon.barlev@gmail.com> wrote:
> > On 1/26/08, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > > The issue is that iproute is just blindly sending the deletes and
> > > not asking for acknowledgment status. Here is a trivial patch to iproute
> > > to fix that, but the problem is that it means it will slow down bulk removal.
> > >
> > > Maybe it should just check the first, or last delete to see if there are
> > > errors?
> > >
> > > diff --git a/ip/iproute.c b/ip/iproute.c
> > > index 7a885b0..b2ae879 100644
> > > --- a/ip/iproute.c
> > > +++ b/ip/iproute.c
> >
> > This should also be applied into ip/ipaddress.c, ip/ipneigh.c
> > Or even make one common function?
> >
> > I don't quite understand how "fast" is good if not complete... But
> > anyway... I will be happy to see this fix in next version... Maybe add
> > --fast argument? :)
> >
> > Alon.
> >


I found the correct solution. The kernel will send back an error after a bad
netlink message, even without ACK. so the code now checks.  Should be checked in
and pushed for next version.


-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
