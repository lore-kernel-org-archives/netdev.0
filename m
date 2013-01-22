From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] IP_GRE: Linearize skb before csum.
Date: Tue, 22 Jan 2013 17:08:26 -0500 (EST)
Message-ID: <20130122.170826.1481012610894653735.davem@davemloft.net>
References: <1358889648-1684-1-git-send-email-pshelar@nicira.com>
	<1358892199.12374.139.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, jesse@nicira.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710Ab3AVWIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 17:08:37 -0500
In-Reply-To: <1358892199.12374.139.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Jan 2013 14:03:19 -0800

> An application changing data provided on a sendfile() or vmsplice() cant
> really expect data integrity being respected, even if checksum are done
> by the NIC (TSO)
> 
> So if data integrity is not respected, just send a bogus TX checksum.

I disagree.

As a quality of implementation decision, we should always compute
correct checksums, ragardless of whether the page contents can be
modified asynchronously during the packet transmit.
