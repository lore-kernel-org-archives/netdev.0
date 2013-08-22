From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: increase throughput when reordering is
 high
Date: Wed, 21 Aug 2013 20:52:28 -0700
Message-ID: <1377143548.4226.134.camel@edumazet-glaptop>
References: <1377131363-31341-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:63590 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506Ab3HVDwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 23:52:30 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld10so1582396pab.8
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 20:52:29 -0700 (PDT)
In-Reply-To: <1377131363-31341-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-21 at 17:29 -0700, Yuchung Cheng wrote:
> The stack currently detects reordering and avoid spurious
> retransmission very well. However the throughput is sub-optimal under
> high reordering because cwnd is increased only if the data is deliverd
> in order. I.e., FLAG_DATA_ACKED check in tcp_ack().  The more packet
> are reordered the worse the throughput is.
> 
> Therefore when reordering is proven high, cwnd should advance whenever
> the data is delivered regardless of its ordering. If reordering is low,
> conservatively advance cwnd only on ordered deliveries in Open state,
> and retain cwnd in Disordered state (RFC5681).
> 
> Using netperf on a qdisc setup of 20Mbps BW and random RTT from 45ms
> to 55ms (for reordering effect). This change increases TCP throughput
> by 20 - 25% to near bottleneck BW.
> 
> A special case is the stretched ACK with new SACK and/or ECE mark.
> For example, a receiver may receive an out of order or ECN packet with
> unacked data buffered because of LRO or delayed ACK. The principle on
> such an ACK is to advance cwnd on the cummulative acked part first,
> then reduce cwnd in tcp_fastretrans_alert().
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_input.c | 32 ++++++++++++++++++++------------
>  1 file changed, 20 insertions(+), 12 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
