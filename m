From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 3/5] tcp: use tcp_v4_send_synack on first SYN-ACK
Date: Mon, 12 May 2014 15:29:07 -0400
Message-ID: <CADVnQymjEjwr4ZSwxQtPqYWB1Rtz-xeRz4dVLByH5HSM_DaEZQ@mail.gmail.com>
References: <1399864933-28287-1-git-send-email-ycheng@google.com>
	<1399864933-28287-4-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, longinus00@gmail.com,
	Jerry Chu <hkchu@google.com>, Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:44372 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbaELT3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 15:29:08 -0400
Received: by mail-wg0-f44.google.com with SMTP id a1so7393653wgh.27
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 12:29:07 -0700 (PDT)
In-Reply-To: <1399864933-28287-4-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 11, 2014 at 11:22 PM, Yuchung Cheng <ycheng@google.com> wrote:
> To avoid large code duplication in IPv6, we need to first simplify
> the complicate SYN-ACK sending code in tcp_v4_conn_request().
>
> To use tcp_v4(6)_send_synack() to send all SYN-ACKs, we need to
> initialize the mini socket's receive window before trying to
> create the child socket and/or building the SYN-ACK packet. So we move
> that initialization from tcp_make_synack() to tcp_v4_conn_request()
> as a new function tcp_openreq_init_req_rwin().
>
> After this refactoring the SYN-ACK sending code is simpler and easier
> to implement Fast Open for IPv6.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Daniel Lee <longinus00@gmail.com>
> Signed-off-by: Jerry Chu <hkchu@google.com>
> ---
>  include/net/tcp.h        | 14 +++++-----
>  net/ipv4/tcp_fastopen.c  | 67 ++++++++++++++++++++++--------------------------
>  net/ipv4/tcp_ipv4.c      | 57 ++++++++++++----------------------------
>  net/ipv4/tcp_minisocks.c | 31 ++++++++++++++++++++++
>  net/ipv4/tcp_output.c    | 21 ---------------
>  5 files changed, 85 insertions(+), 105 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
