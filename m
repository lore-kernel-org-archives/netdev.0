From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix panic when sending auth chunks
Date: Sat, 09 Jul 2016 00:08:54 -0400 (EDT)
Message-ID: <20160709.000854.945698278700890168.davem@davemloft.net>
References: <433dedb6a14cd5bd59ad2f82579d872b97171727.1467894889.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	nhorman@tuxdriver.com, vyasevich@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627AbcGIEI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 00:08:56 -0400
In-Reply-To: <433dedb6a14cd5bd59ad2f82579d872b97171727.1467894889.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Thu,  7 Jul 2016 09:39:29 -0300

> When we introduced GSO support, if using auth the auth chunk was being
> left queued on the packet even after the final segment was generated.
> Later on sctp_transmit_packet it calls sctp_packet_reset, which zeroed
> the packet len while not accounting for this left-over. This caused more
> space to be used the next packet due to the chunk still being queued,
> but space which wasn't allocated as its size wasn't accounted.
> 
> The fix is to only queue it back when we know that we are going to
> generate another segment.
> 
> Fixes: 90017accff61 ("sctp: Add GSO support")
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied to net-next.

Please make the target tree for your patch explicit in future
submissions.

Thanks.
