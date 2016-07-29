From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: consider recv buf for the initial window scale
Date: Fri, 29 Jul 2016 09:21:34 -0400
Message-ID: <CADVnQynVYi1Yz983GiLnO_9gpkugeC-7V6ecoCdJBuUe75riiw@mail.gmail.com>
References: <1469761894-26014-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:35436 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbcG2NWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 09:22:04 -0400
Received: by mail-oi0-f51.google.com with SMTP id l72so105915057oig.2
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2016 06:22:04 -0700 (PDT)
In-Reply-To: <1469761894-26014-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 28, 2016 at 11:11 PM, Soheil Hassas Yeganeh
<soheil.kdev@gmail.com> wrote:
>
> From: Soheil Hassas Yeganeh <soheil@google.com>
>
> tcp_select_initial_window() intends to advertise a window
> scaling for the maximum possible window size. To do so,
> it considers the maximum of net.ipv4.tcp_rmem[2] and
> net.core.rmem_max as the only possible upper-bounds.
> However, users with CAP_NET_ADMIN can use SO_RCVBUFFORCE
> to set the socket's receive buffer size to values
> larger than net.ipv4.tcp_rmem[2] and net.core.rmem_max.
> Thus, SO_RCVBUFFORCE is effectively ignored by
> tcp_select_initial_window().
>
> To fix this, consider the maximum of net.ipv4.tcp_rmem[2],
> net.core.rmem_max and socket's initial buffer space.
>
> This part of the code does not have git history and as a
> result this patch does not have a `Fixes:` tag.
>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Suggested-by: Neal Cardwell <ncardwell@google.com>

I think it makes sense to tag this commit with:

Fixes: b0573dea1fb3 ("[NET]: Introduce SO_{SND,RCV}BUFFORCE socket options")

... because that's the moment at which this line of code started
failing to achieve its stated objective of setting the window scaling
factor based on the max possible window.

And having a Fixes tag would help maintainers figure out that the
patch makes sense to apply to kernels after that commit.

thanks,
neal
