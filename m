From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Wed, 18 Dec 2013 07:20:00 +0100
Message-ID: <20131218062000.GC27460@order.stressinduktion.org>
References: <CAJFZqHwF0ubvxJOs2BWbSMMB1szKNO=XTiXje3E2ByF6sUQrXA@mail.gmail.com> <52AFE7E3.3070806@cn.fujitsu.com> <CAJFZqHxawisUbHGZY8mjGHy8035X6TQ7FNzc20vtS5j1jdZYGA@mail.gmail.com> <20131217070231.GA11970@order.stressinduktion.org> <52B00150.3070002@cn.fujitsu.com> <20131217134823.GC18396@order.stressinduktion.org> <52B0F0C4.1010803@cn.fujitsu.com> <CAJFZqHywaN4k64zd-fcw7=DD+6iNX_Psuwi2QKH_GX-_04TVSg@mail.gmail.com> <52B103DE.7090604@cn.fujitsu.com> <CAJFZqHxB8PscqXnX9oxpHf8zFyW1hyCZVZTn_=DoKebN3X2ZGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Gao feng <gaofeng@cn.fujitsu.com>, netdev@vger.kernel.org
To: RongQing Li <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35389 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316Ab3LRGUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 01:20:03 -0500
Content-Disposition: inline
In-Reply-To: <CAJFZqHxB8PscqXnX9oxpHf8zFyW1hyCZVZTn_=DoKebN3X2ZGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 10:21:12AM +0800, RongQing Li wrote:
> On Wed, Dec 18, 2013 at 10:09 AM, Gao feng <gaofeng@cn.fujitsu.com> wrote:
> > On 12/18/2013 09:58 AM, RongQing Li wrote:
> >> On Wed, Dec 18, 2013 at 8:48 AM, Gao feng <gaofeng@cn.fujitsu.com> wrote:
> >>> On 12/17/2013 09:48 PM, Hannes Frederic Sowa wrote:
> >>>> On Tue, Dec 17, 2013 at 03:46:24PM +0800, Gao feng wrote:
> >>>>> The from of new cloned rt should not be set if it's impossible for the ort
> >>>>> to be expired.
> >>>>
> >>>> Actually, why do you think so? What could go wrong?
> >>>>
> >>>
> >>> I just don't want rt6_check_expired to check some impossible expired routes.
> >>>
> >>
> >> What is wrong if we set from for new cloned rt by checking if ort has
> >> RTF_EXPIRES flag?
> >
> >
> > The RTF_EXPIRES flag may be changed by router advertisment package,
> > the ort may become expired after you hadn't set from for new cloned rt.
> >
> > we should set from even this kind of ort doesn't have RTF_EXPIRES flag.
> 
> 
> Thanks;
> 
> Do we want to set from only from RA route?  if so,  we should check
> ort with RTF_ADDRCONF|RTF_DEFAULT, or RTF_ADDRCONF | RTF_ROUTEINFO,

Nope, as I said, also prefix routes which did get installed by hand locally
can have an expiration. I don't see any flag combination which ensure a
potential from does never expire. IMHO we should always from.

Also, in case we overwrite a route and the route is already in there, we reset
the expiry values: search for rt6_set_expires in fib6_add_rt2node.

We had the same problem with ECMP routes. We only wanted to add non-expiration
routes but we could not find a combination which did ensure that. In the end
we now also add non-expiration routes to an ecmp set (see commit
307f2fb95e9b96).

Greetings,

  Hannes
