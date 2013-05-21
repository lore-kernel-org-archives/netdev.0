From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: bug fix in proportional rate reduction.
Date: Mon, 20 May 2013 21:46:51 -0400
Message-ID: <CADVnQyk=3iVMkH+5UioPMV1-MDCdmjsHSzAD5Lwww40b+Cp-9w@mail.gmail.com>
References: <1369095724-17745-1-git-send-email-nanditad@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:64476 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755245Ab3EUBqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 21:46:53 -0400
Received: by mail-ea0-f175.google.com with SMTP id h10so42428eaj.20
        for <netdev@vger.kernel.org>; Mon, 20 May 2013 18:46:51 -0700 (PDT)
In-Reply-To: <1369095724-17745-1-git-send-email-nanditad@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 20, 2013 at 8:22 PM, Nandita Dukkipati <nanditad@google.com> wrote:
> This patch is a fix for a bug triggering newly_acked_sacked < 0
> in tcp_ack(.).
>
> The bug is triggered by sacked_out decreasing relative to prior_sacked,
> but packets_out remaining the same as pior_packets. This is because the
> snapshot of prior_packets is taken after tcp_sacktag_write_queue() while
> prior_sacked is captured before tcp_sacktag_write_queue(). The problem
> is: tcp_sacktag_write_queue (tcp_match_skb_to_sack() -> tcp_fragment)
> adjusts the pcount for packets_out and sacked_out (MSS change or other
> reason). As a result, this delta in pcount is reflected in
> (prior_sacked - sacked_out) but not in (prior_packets - packets_out).
>
> This patch does the following:
> 1) initializes prior_packets at the start of tcp_ack() so as to
> capture the delta in packets_out created by tcp_fragment.
> 2) introduces a new "previous_packets_out" variable that snapshots
> packets_out right before tcp_clean_rtx_queue, so pkts_acked can be
> correctly computed as before.
>
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> ---
>  net/ipv4/tcp_input.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
