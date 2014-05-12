From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH 0/5] tcp: IPv6 support for fastopen server
Date: Sun, 11 May 2014 20:26:21 -0700
Message-ID: <CAK6E8=dR0MrRtwi=LtihoHXXxbynao8C9mAYc29riVdP6--6TA@mail.gmail.com>
References: <1399864933-28287-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Lee <longinus00@gmail.com>, Jerry Chu <hkchu@google.com>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:38458 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbaELD1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 23:27:02 -0400
Received: by mail-ie0-f169.google.com with SMTP id lx4so768556iec.14
        for <netdev@vger.kernel.org>; Sun, 11 May 2014 20:27:01 -0700 (PDT)
In-Reply-To: <1399864933-28287-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 11, 2014 at 8:22 PM, Yuchung Cheng <ycheng@google.com> wrote:
> This patch series add IPv6 support for fastopen server. To minimize
> code duplication in IPv4 and IPv6, the current v4 only code is
> refactored and common code is moved into net/ipv4/tcp_fastopen.c.
>
> Also the current code uses a different function from
> tcp_v4_send_synack() to send the first SYN-ACK in fastopen.
> The new code eliminates this separate function by refactoring the
> child-socket and syn-ack creation code.  After these refactoring
> in the first four patches, we can easily add the fastopen code in
> IPv6 by changing corresponding IPv6 functions.
>
> Note Fast Open client already supports IPv6. This patch is for
> the server-side (passive open) IPv6 support only.

Sorry I forget to mention the patches are for net-next. Let me know if
I should re-submit with the proper subject line.

>
> Daniel Lee (1):
>   tcp: IPv6 support for fastopen server
>
> Yuchung Cheng (4):
>   tcp: move fastopen functions to tcp_fastopen.c
>   tcp: simplify fast open cookie processing
>   tcp: use tcp_v4_send_synack on first SYN-ACK
>   tcp: improve fastopen icmp handling
>
>  include/linux/tcp.h      |   5 -
>  include/net/tcp.h        |  15 ++-
>  net/ipv4/tcp_fastopen.c  | 219 +++++++++++++++++++++++++++++++++++--
>  net/ipv4/tcp_ipv4.c      | 277 +++++------------------------------------------
>  net/ipv4/tcp_minisocks.c |  31 ++++++
>  net/ipv4/tcp_output.c    |  23 +---
>  net/ipv6/tcp_ipv6.c      |  62 ++++++++---
>  7 files changed, 323 insertions(+), 309 deletions(-)
>
> --
> 1.9.1.423.g4596e3a
>
