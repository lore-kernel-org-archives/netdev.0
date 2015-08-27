From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vrf: Add ethernet header for pass through VRF
 device
Date: Wed, 26 Aug 2015 17:30:58 -0700 (PDT)
Message-ID: <20150826.173058.1864374511836166828.davem@davemloft.net>
References: <55DCEE43.4000200@cumulusnetworks.com>
	<20150825.155108.983138344238637012.davem@davemloft.net>
	<55DE152F.10701@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbbH0Aa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 20:30:59 -0400
In-Reply-To: <55DE152F.10701@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 26 Aug 2015 12:36:15 -0700

> As such all we need is to push an eth header to the front of the skb
> for 1 loop through the stack and eth_header via dev_hard_header with
> NULL daddr is the simplest path to accomplish that. Any other path is
> just extra overhead.

And dev_hard_header() is full of conditional code and partial stores,
whereas the hard header cache is a _SINGLE UNCONDITIONAL MEMCPY_.

You're making this data path more expensive than it needs to be just
to placate features which in no way are default situations.
