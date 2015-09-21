From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: usec resolution SYN/ACK RTT
Date: Mon, 21 Sep 2015 16:19:14 -0700 (PDT)
Message-ID: <20150921.161914.1871041800702197631.davem@davemloft.net>
References: <1442601374-27885-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbbIUXTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 19:19:15 -0400
In-Reply-To: <1442601374-27885-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Fri, 18 Sep 2015 11:36:14 -0700

> Currently SYN/ACK RTT is measured in jiffies. For LAN the SYN/ACK
> RTT is often measured as 0ms or sometimes 1ms, which would affect
> RTT estimation and min RTT samping used by some congestion control.
> 
> This patch improves SYN/ACK RTT to be usec resolution if platform
> supports it. While the timestamping of SYN/ACK is done in request
> sock, the RTT measurement is carefully arranged to avoid storing
> another u64 timestamp in tcp_sock.
> 
> For regular handshake w/o SYNACK retransmission, the RTT is sampled
> right after the child socket is created and right before the request
> sock is released (tcp_check_req() in tcp_minisocks.c)
> 
> For Fast Open the child socket is already created when SYN/ACK was
> sent, the RTT is sampled in tcp_rcv_state_process() after processing
> the final ACK an right before the request socket is released.
> 
> If the SYN/ACK was retransmistted or SYN-cookie was used, we rely
> on TCP timestamps to measure the RTT. The sample is taken at the
> same place in tcp_rcv_state_process() after the timestamp values
> are validated in tcp_validate_incoming(). Note that we do not store
> TS echo value in request_sock for SYN-cookies, because the value
> is already stored in tp->rx_opt used by tcp_ack_update_rtt().
> 
> One side benefit is that the RTT measurement now happens before
> initializing congestion control (of the passive side). Therefore
> the congestion control can use the SYN/ACK RTT.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
