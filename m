From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Tue, 17 Dec 2013 08:02:31 +0100
Message-ID: <20131217070231.GA11970@order.stressinduktion.org>
References: <1387182666-31301-1-git-send-email-roy.qing.li@gmail.com> <52AFC43C.9080804@cn.fujitsu.com> <CAJFZqHwF0ubvxJOs2BWbSMMB1szKNO=XTiXje3E2ByF6sUQrXA@mail.gmail.com> <52AFE7E3.3070806@cn.fujitsu.com> <CAJFZqHxawisUbHGZY8mjGHy8035X6TQ7FNzc20vtS5j1jdZYGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Gao feng <gaofeng@cn.fujitsu.com>, netdev@vger.kernel.org
To: RongQing Li <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60814 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab3LQHCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 02:02:33 -0500
Content-Disposition: inline
In-Reply-To: <CAJFZqHxawisUbHGZY8mjGHy8035X6TQ7FNzc20vtS5j1jdZYGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 02:42:01PM +0800, RongQing Li wrote:
> On 12/17/13, Gao feng <gaofeng@cn.fujitsu.com> wrote:
> > On 12/17/2013 11:32 AM, RongQing Li wrote:
> >> If the ort->rt6i_flags is RTF_EXPIRES|RTF_ADDRCONF, then rt6_set_from will
> >> not
> >> be called, and new created rt will have RTF_EXPIRES, but dst.expires is 0,
> >> and
> >> dst.from is NULL
> >
> > Ok, but I think you need to add more detail/test purpose of the test case
> > v6LC.4.1.4
> > { Reduce PMTU On-link }. just the number of test case is not good for people
> > to know
> > what's the real problem.
> >
> 
> I have a question, why does we set dst.from only when the ort has flag
> RTF_ADDRCONF
> and RTF_DEFAULT?

Good question. ;)

I wonder, too. In the past from and expires were a union and either from or
expires was allowed to be used. In the commit you referred to this union was
split into seperate fields.

It somehow worked in the past because routes normally have longer timeouts
and the routes will get evicted from the route cache eventually. My guess
is that we can set from unconditionally or copy over the expires value.

This patch already needed quite a long time to review for me and I am still
unsure. :/

Gao, do you still remember why you used RTF_ADDRCONF|RTF_DEFAULT?

Greetings,

  Hannes
