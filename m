From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Tue, 19 Jun 2012 21:46:57 -0700 (PDT)
Message-ID: <20120619.214657.1345825814176201681.davem@davemloft.net>
References: <20120619.163911.2094057156011157978.davem@davemloft.net>
	<20120619193549.13bcffa7@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174Ab2FTEq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 00:46:58 -0400
In-Reply-To: <20120619193549.13bcffa7@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 19 Jun 2012 19:35:49 -0700

> Any benchmark numbers?

Measuring the path from ip_rcv_finish() to where we lock the socket in
tcp_v4_rcv(), on a SPARC-T3, with a pre-warmed routing cache:

Both sk and RT lookup:	~4200 cycles
Optimized early demux:	~2800 cycles

These numbers can be decreased further, because since we're already
looking at the TCP header we can pre-cook the TCP control block in the
SKB and skip much of the stuff that tcp_v4_rcv() does since we've done
it already in the early demux code.

> I think the number of ref count operations per packet is going to be
> the next line in the sand.

There is only one, for the socket.  We haven't taken a reference on the
route for years.
