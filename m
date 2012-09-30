From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7 net-next v2] tg3: Disable multiple TX rings by
 default due to hardware flaw
Date: Sun, 30 Sep 2012 02:12:51 -0400 (EDT)
Message-ID: <20120930.021251.1431834423231117398.davem@davemloft.net>
References: <1348852363-8582-5-git-send-email-mchan@broadcom.com>
	<1348852363-8582-6-git-send-email-mchan@broadcom.com>
	<1348852363-8582-7-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54939 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433Ab2I3GMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2012 02:12:52 -0400
In-Reply-To: <1348852363-8582-7-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 28 Sep 2012 10:12:43 -0700

> Simple round-robin hardware TX scheduling can cause starvation of TX rings
> with small packets when other TX rings have large TSO or jumbo packets.
> 
> In the simplest case, consider 2 TCP streams running in opposite
> directions.  The TSO TX traffic will hash to one ring and the ACKs for the
> incoming data on a different TCP connection will hash to a different TX
> ring.  The hardware fetches one complete TSO packet (up to 64K data)
> before servicing the other TX ring.  When it gets to the other TX ring, it
> will only fetch one packet (64-byte ACK packet in this case).  After that,
> it will switch back to the 1st ring filled with more TSO packets.  Because
> only one ACK can go out roughly every 500 usec in this case, the incoming
> data rate becomes very low.
> 
> Update version to 3.125.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
