From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4 net-next] tcp: fix undo on partial ack in recovery
Date: Thu, 30 May 2013 18:07:28 -0700 (PDT)
Message-ID: <20130530.180728.50725302633946582.davem@davemloft.net>
References: <1369873214-29502-1-git-send-email-ycheng@google.com>
	<1369873214-29502-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, nanditad@google.com,
	aterzis@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136Ab3EaBH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 21:07:29 -0400
In-Reply-To: <1369873214-29502-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 29 May 2013 17:20:13 -0700

> Upon detecting spurious fast retransmit via timestamps during recovery,
> use PRR to clock out new data packet instead of retransmission. Once
> all retransmission are proven spurious, the sender then reverts the
> cwnd reduction and congestion state to open or disorder.
> 
> The current code does the opposite: it undoes cwnd as soon as any
> retransmission is spurious and continues to retransmit until all
> data are acked. This nullifies the point to undo the cwnd because
> the sender is still retransmistting spuriously. This patch fixes
> it. The undo_ssthresh argument of tcp_undo_cwnd_reductiuon() is no
> longer needed and is removed.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied.
