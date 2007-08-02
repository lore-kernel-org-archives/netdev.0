From: Jeff Garzik <jeff@garzik.org>
Subject: Re: net driver error accounting
Date: Thu, 02 Aug 2007 16:38:09 -0400
Message-ID: <46B240B1.9080003@garzik.org>
References: <20070802131718.84543097.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Natalie Protasevich <protasnb@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47242 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456AbXHBUiN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 16:38:13 -0400
In-Reply-To: <20070802131718.84543097.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Looking at http://bugzilla.kernel.org/show_bug.cgi?id=8106
> 
> Guys, could we please have a ruling here?
> 
> When a net driver encounters a tx_fifo_error, should this also contribute
> to the tx_error count, or should it not?

For each TX error, (a) tx_error is incremented and (b) a more-specific 
TX error stat is also potentially incremented.  So, yes, tx_error 
accumulates.

See cp_tx() in 8139cp.


> More generally, should netdev drivers accumulate all the detailed
> rx_errors into net_device_stats.rx_errors in real time, or should they not?

For each RX error, (a) rx_error is incremented and (b) a more-specific 
RX error stat is also potentially incremented.  So, yes, rx_error 
accumulates.

See cp_rx_err_acct() in 8139cp.

	Jeff


