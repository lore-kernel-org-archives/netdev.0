From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: do not rearm RTO when future data are sacked
Date: Thu, 24 Oct 2013 13:03:18 -0400
Message-ID: <CADVnQymvjvnckyUVK7kJaw0XVZ0uaPU2D44nCLuwM3Tv0qpt0A@mail.gmail.com>
References: <1382630367-21964-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Lawrence Brakmo <brakmo@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:49317 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755669Ab3JXRDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 13:03:19 -0400
Received: by mail-ea0-f174.google.com with SMTP id z15so1362787ead.19
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 10:03:18 -0700 (PDT)
In-Reply-To: <1382630367-21964-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 24, 2013 at 11:59 AM, Yuchung Cheng <ycheng@google.com> wrote:
> Patch ed08495c3 "tcp: use RTT from SACK for RTO" always re-arms RTO upon
> obtaining a RTT sample from newly sacked data.
>
> But technically RTO should only be re-armed when the data sent before
> the last (re)transmission of write queue head are (s)acked. Otherwise
> the RTO may continue to extend during loss recovery on data sent
> in the future.
>
> Note that RTTs from ACK or timestamps do not have this problem, as the RTT
> source must be from data sent before.
>
> The new RTO re-arm policy is
> 1) Always re-arm RTO if SND.UNA is advanced
> 2) Re-arm RTO if sack RTT is available, provided the sacked data was
>    sent before the last time write_queue_head was sent.
>
> Signed-off-by: Larry Brakmo <brakmo@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_input.c | 13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
