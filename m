From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] tcp: TCP Fast Open Server - call
 tcp_validate_incoming() for all packets
Date: Sat, 22 Sep 2012 15:48:02 -0400 (EDT)
Message-ID: <20120922.154802.549925222027300949.davem@davemloft.net>
References: <1348323537-30310-1-git-send-email-ncardwell@google.com>
	<1348323537-30310-4-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ycheng@google.com,
	hkchu@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34825 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329Ab2IVTsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 15:48:04 -0400
In-Reply-To: <1348323537-30310-4-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sat, 22 Sep 2012 10:18:57 -0400

> A TCP Fast Open (TFO) passive connection must call both
> tcp_check_req() and tcp_validate_incoming() for all incoming ACKs that
> are attempting to complete the 3WHS.
> 
> This is needed to parallel all the action that happens for a non-TFO
> connection, where for an ACK that is attempting to complete the 3WHS
> we call both tcp_check_req() and tcp_validate_incoming().
> 
> For example, upon receiving the ACK that completes the 3WHS, we need
> to call tcp_fast_parse_options() and update ts_recent based on the
> incoming timestamp value in the ACK.
> 
> One symptom of the problem with the previous code was that for passive
> TFO connections using TCP timestamps, the outgoing TS ecr values
> ignored the incoming TS val value on the ACK that completed the 3WHS.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
