From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: allow sctp_transmit_packet and others to use gfp
Date: Sun, 13 Mar 2016 22:29:21 -0400 (EDT)
Message-ID: <20160313.222921.1815217477750936019.davem@davemloft.net>
References: <90a118e4ca996adb067290a6c45fca6564a77423.1457644344.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754254AbcCNC3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 22:29:25 -0400
In-Reply-To: <90a118e4ca996adb067290a6c45fca6564a77423.1457644344.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Thu, 10 Mar 2016 18:33:07 -0300

> Currently sctp_sendmsg() triggers some calls that will allocate memory
> with GFP_ATOMIC even when not necessary. In the case of
> sctp_packet_transmit it will allocate a linear skb that will be used to
> construct the packet and this may cause sends to fail due to ENOMEM more
> often than anticipated specially with big MTUs.
> 
> This patch thus allows it to inherit gfp flags from upper calls so that
> it can use GFP_KERNEL if it was triggered by a sctp_sendmsg call or
> similar. All others, like retransmits or flushes started from BH, are
> still allocated using GFP_ATOMIC.
> 
> In netperf tests this didn't result in any performance drawbacks when
> memory is not too fragmented and made it trigger ENOMEM way less often.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied, thanks.
