From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix FRTO undo on cumulative ACK of SACKed
 range
Date: Thu, 02 Apr 2015 16:36:57 -0400 (EDT)
Message-ID: <20150402.163657.2253989632178525489.davem@davemloft.net>
References: <1427934406-18743-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41301 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbbDBUhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 16:37:00 -0400
In-Reply-To: <1427934406-18743-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Wed,  1 Apr 2015 20:26:46 -0400

> On processing cumulative ACKs, the FRTO code was not checking the
> SACKed bit, meaning that there could be a spurious FRTO undo on a
> cumulative ACK of a previously SACKed skb.
> 
> The FRTO code should only consider a cumulative ACK to indicate that
> an original/unretransmitted skb is newly ACKed if the skb was not yet
> SACKed.
> 
> The effect of the spurious FRTO undo would typically be to make the
> connection think that all previously-sent packets were in flight when
> they really weren't, leading to a stall and an RTO.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Fixes: e33099f96d99c ("tcp: implement RFC5682 F-RTO")

Applied and queued up for -stable, thanks Neal.
