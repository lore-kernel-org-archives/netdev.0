From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net] tcp: consider recv buf for the initial window scale
Date: Fri, 29 Jul 2016 09:32:28 -0400
Message-ID: <CACSApva3wPs3uXqVuoV7D3y98feWLmo+owGk=E5VuCsjUfWY3w@mail.gmail.com>
References: <1469761894-26014-1-git-send-email-soheil.kdev@gmail.com> <CADVnQynVYi1Yz983GiLnO_9gpkugeC-7V6ecoCdJBuUe75riiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:32841 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458AbcG2NdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 09:33:08 -0400
Received: by mail-oi0-f54.google.com with SMTP id j185so105962294oih.0
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2016 06:33:08 -0700 (PDT)
In-Reply-To: <CADVnQynVYi1Yz983GiLnO_9gpkugeC-7V6ecoCdJBuUe75riiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 29, 2016 at 9:21 AM, Neal Cardwell <ncardwell@google.com> wrote:
>
> On Thu, Jul 28, 2016 at 11:11 PM, Soheil Hassas Yeganeh
> <soheil.kdev@gmail.com> wrote:
> >
> > From: Soheil Hassas Yeganeh <soheil@google.com>
> >
> > tcp_select_initial_window() intends to advertise a window
> > scaling for the maximum possible window size. To do so,
> > it considers the maximum of net.ipv4.tcp_rmem[2] and
> > net.core.rmem_max as the only possible upper-bounds.
> > However, users with CAP_NET_ADMIN can use SO_RCVBUFFORCE
> > to set the socket's receive buffer size to values
> > larger than net.ipv4.tcp_rmem[2] and net.core.rmem_max.
> > Thus, SO_RCVBUFFORCE is effectively ignored by
> > tcp_select_initial_window().
> >
> > To fix this, consider the maximum of net.ipv4.tcp_rmem[2],
> > net.core.rmem_max and socket's initial buffer space.
> >
> > This part of the code does not have git history and as a
> > result this patch does not have a `Fixes:` tag.
> >
> > Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> > Suggested-by: Neal Cardwell <ncardwell@google.com>
>
> I think it makes sense to tag this commit with:
>
> Fixes: b0573dea1fb3 ("[NET]: Introduce SO_{SND,RCV}BUFFORCE socket options")

Thanks for noting the SHA1. I'll send a v2.

Thanks,
Soheil

> ... because that's the moment at which this line of code started
> failing to achieve its stated objective of setting the window scaling
> factor based on the max possible window.
>
> And having a Fixes tag would help maintainers figure out that the
> patch makes sense to apply to kernels after that commit.
>
> thanks,
> neal
