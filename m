From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4] netem: Segment GSO packets on enqueue
Date: Tue, 03 May 2016 00:34:03 -0400 (EDT)
Message-ID: <20160503.003403.425735624710254974.davem@davemloft.net>
References: <1461692618-21333-1-git-send-email-nhorman@tuxdriver.com>
	<1462206015-3484-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	netem@lists.linux-foundation.org, eric.dumazet@gmail.com,
	stephen@networkplumber.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848AbcECEeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 00:34:07 -0400
In-Reply-To: <1462206015-3484-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon,  2 May 2016 12:20:15 -0400

> This was recently reported to me, and reproduced on the latest net kernel,
> when attempting to run netperf from a host that had a netem qdisc attached
> to the egress interface:
 ...
> The problem occurs because netem is not prepared to handle GSO packets (as it
> uses skb_checksum_help in its enqueue path, which cannot manipulate these
> frames).
> 
> The solution I think is to simply segment the skb in a simmilar fashion to the
> way we do in __dev_queue_xmit (via validate_xmit_skb), with some minor changes.
> When we decide to corrupt an skb, if the frame is GSO, we segment it, corrupt
> the first segment, and enqueue the remaining ones.
> 
> tested successfully by myself on the latest net kernel, to which this applies
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied and queued up for -stable, thanks Neil.
