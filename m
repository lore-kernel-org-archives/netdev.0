From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] sctp: donot reset the overall_error_count in
 SHUTDOWN_RECEIVE state
Date: Thu, 27 Aug 2015 17:12:06 -0700 (PDT)
Message-ID: <20150827.171206.1343630245407773111.davem@davemloft.net>
References: <5b69e6d52b777923b9224315d11adbf9bd24077e.1440622340.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mleitner@redhat.com, vyasevic@redhat.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48495 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbbH1AMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 20:12:18 -0400
In-Reply-To: <5b69e6d52b777923b9224315d11adbf9bd24077e.1440622340.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 27 Aug 2015 04:52:20 +0800

> Commit f8d960524328 ("sctp: Enforce retransmission limit during shutdown")
> fixed a problem with excessive retransmissions in the SHUTDOWN_PENDING by not
> resetting the association overall_error_count.  This allowed the association
> to better enforce assoc.max_retrans limit.
> 
> However, the same issue still exists when the association is in SHUTDOWN_RECEIVED
> state.  In this state, HB-ACKs will continue to reset the overall_error_count
> for the association would extend the lifetime of association unnecessarily.
> 
> This patch solves this by resetting the overall_error_count whenever the current
> state is small then SCTP_STATE_SHUTDOWN_PENDING.  As a small side-effect, we
> end up also handling SCTP_STATE_SHUTDOWN_ACK_SENT and SCTP_STATE_SHUTDOWN_SENT
> states, but they are not really impacted because we disable Heartbeats in those
> states.
> 
> Fixes: Commit f8d960524328 ("sctp: Enforce retransmission limit during shutdown")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thanks.
