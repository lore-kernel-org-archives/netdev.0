From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 1/1] tcp: Prevent needless syn-ack rexmt during TWHS
Date: Thu, 25 Oct 2012 23:31:46 -0400
Message-ID: <CADVnQynogLLze3B3PqUpKf-mZf3NobHXrfpZdPEc7Kbtxcd0NA@mail.gmail.com>
References: <1351212356-11964-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliot Hughes <enh@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:63805 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755893Ab2JZDbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 23:31:47 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so1867816iag.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 20:31:46 -0700 (PDT)
In-Reply-To: <1351212356-11964-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 25, 2012 at 8:45 PM, Vijay Subramanian
<subramanian.vijay@gmail.com> wrote:
> If server socket is slow to accept() connections, request_socks can represent
> connections for which the three-way handshake is already done.  From client's
> point of view, the connection is in ESTABLISHED state but on server side, socket
> is not in accept_queue or ESTABLISHED state.  When the syn-ack timer expires,
> because of the order in which tests are performed, server can retransmit the
> synack repeatedly. Following patch prevents the server from retransmitting the
> synack needlessly (and prevents client from replying with ack).  This reduces
> traffic when server is slow to accept() connections.
>
> If the server socket has received the third ack during connection establishment,
> this is remembered in inet_rsk(req)->acked.  The request_sock will expire in
> around 30 seconds and will be dropped if it does not move into accept_queue.
>
> With help from Eric Dumazet.
>
> Reported-by: Elliot Hughes <enh@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>
Tested-by: Neal Cardwell <ncardwell@google.com>

Nice. Verified the bug and the fix.

neal
