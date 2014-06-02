From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix cwnd undo on DSACK in F-RTO
Date: Mon, 02 Jun 2014 16:51:08 -0700 (PDT)
Message-ID: <20140602.165108.2242251071382244547.davem@davemloft.net>
References: <1401488759-22637-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955AbaFBXvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 19:51:09 -0400
In-Reply-To: <1401488759-22637-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Fri, 30 May 2014 15:25:59 -0700

> This bug is discovered by an recent F-RTO issue on tcpm list
> https://www.ietf.org/mail-archive/web/tcpm/current/msg08794.html
> 
> The bug is that currently F-RTO does not use DSACK to undo cwnd in
> certain cases: upon receiving an ACK after the RTO retransmission in
> F-RTO, and the ACK has DSACK indicating the retransmission is spurious,
> the sender only calls tcp_try_undo_loss() if some never retransmisted
> data is sacked (FLAG_ORIG_DATA_SACKED).
> 
> The correct behavior is to unconditionally call tcp_try_undo_loss so
> the DSACK information is used properly to undo the cwnd reduction.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied and queued up for -stable, thanks.
