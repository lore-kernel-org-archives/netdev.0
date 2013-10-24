From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: do not rearm RTO when future data are sacked
Date: Thu, 24 Oct 2013 12:58:14 -0700
Message-ID: <1382644694.7572.61.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382630367-21964-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	brakmo@google.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:41771 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755269Ab3JXT6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 15:58:20 -0400
Received: by mail-we0-f180.google.com with SMTP id q59so2891357wes.11
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 12:58:19 -0700 (PDT)
In-Reply-To: <1382630367-21964-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-24 at 08:59 -0700, Yuchung Cheng wrote:
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

Acked-by: Eric Dumazet <edumazet@google.com>
