From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] tcp: TCP Fast Open Server - take SYNACK
 RTT after completing 3WHS
Date: Sat, 22 Sep 2012 15:47:50 -0400 (EDT)
Message-ID: <20120922.154750.2204702068231856030.davem@davemloft.net>
References: <1348323537-30310-1-git-send-email-ncardwell@google.com>
	<1348323537-30310-2-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ycheng@google.com,
	hkchu@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836Ab2IVTrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 15:47:52 -0400
In-Reply-To: <1348323537-30310-2-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sat, 22 Sep 2012 10:18:55 -0400

> When taking SYNACK RTT samples for servers using TCP Fast Open, fix
> the code to ensure that we only call tcp_valid_rtt_meas() after we
> receive the ACK that completes the 3-way handshake.
> 
> Previously we were always taking an RTT sample in
> tcp_v4_syn_recv_sock(). However, for TCP Fast Open connections
> tcp_v4_conn_req_fastopen() calls tcp_v4_syn_recv_sock() at the time we
> receive the SYN. So for TFO we must wait until tcp_rcv_state_process()
> to take the RTT sample.
> 
> To fix this, we wait until after TFO calls tcp_v4_syn_recv_sock()
> before we set the snt_synack timestamp, since tcp_synack_rtt_meas()
> already ensures that we only take a SYNACK RTT sample if snt_synack is
> non-zero. To be careful, we only take a snt_synack timestamp when
> a SYNACK transmit or retransmit succeeds.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
