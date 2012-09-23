From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: TCP Fast Open Server - record
 retransmits after 3WHS
Date: Sat, 22 Sep 2012 23:15:50 -0400 (EDT)
Message-ID: <20120922.231550.592470091328581312.davem@davemloft.net>
References: <1348369427-29563-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ycheng@google.com,
	hkchu@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab2IWDPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 23:15:55 -0400
In-Reply-To: <1348369427-29563-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sat, 22 Sep 2012 23:03:47 -0400

> When recording the number of SYNACK retransmits for servers using TCP
> Fast Open, fix the code to ensure that we copy over the retransmit
> count from the request_sock after we receive the ACK that completes
> the 3-way handshake.
> 
> The story here is similar to that of SYNACK RTT
> measurements. Previously we were always doing this in
> tcp_v4_syn_recv_sock(). However, for TCP Fast Open connections
> tcp_v4_conn_req_fastopen() calls tcp_v4_syn_recv_sock() at the time we
> receive the SYN. So for TFO we must copy the final SYNACK retransmit
> count in tcp_rcv_state_process().
> 
> Note that copying over the SYNACK retransmit count will give us the
> correct count since, as is mentioned in a comment in
> tcp_retransmit_timer(), before we receive an ACK for our SYN-ACK a TFO
> passive connection does not retransmit anything else (e.g., data or
> FIN segments).
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks Neal.
