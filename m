From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] tcp: TCP Fast Open Server - note
 timestamps and retransmits for SYNACK RTT
Date: Sat, 22 Sep 2012 15:47:56 -0400 (EDT)
Message-ID: <20120922.154756.544063808703856009.davem@davemloft.net>
References: <1348323537-30310-1-git-send-email-ncardwell@google.com>
	<1348323537-30310-3-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ycheng@google.com,
	hkchu@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34819 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836Ab2IVTr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 15:47:58 -0400
In-Reply-To: <1348323537-30310-3-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sat, 22 Sep 2012 10:18:56 -0400

> Previously, when using TCP Fast Open a server would return from
> tcp_check_req() before updating snt_synack based on TCP timestamp echo
> replies and whether or not we've retransmitted the SYNACK. The result
> was that (a) for TFO connections using timestamps we used an incorrect
> baseline SYNACK send time (tcp_time_stamp of SYNACK send instead of
> rcv_tsecr), and (b) for TFO connections that do not have TCP
> timestamps but retransmit the SYNACK we took a SYNACK RTT sample when
> we should not take a sample.
> 
> This fix merely moves the snt_synack update logic a bit earlier in the
> function, so that connections using TCP Fast Open will properly do
> these updates when the ACK for the SYNACK arrives.
> 
> Moving this snt_synack update logic means that with TCP_DEFER_ACCEPT
> enabled we do a few instructions of wasted work on each bare ACK, but
> that seems OK.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
