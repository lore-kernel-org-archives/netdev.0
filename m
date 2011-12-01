From: David Miller <davem@davemloft.net>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Thu, 01 Dec 2011 13:04:03 -0500 (EST)
Message-ID: <20111201.130403.1392783813860983313.davem@davemloft.net>
References: <CA+mtBx9fE0qQc-LndM03ykhVMV5n9Z4KHcD6PpTiy=M79GOnKw@mail.gmail.com>
	<1322730937.2335.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111201092950.00006ce8@unknown>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755956Ab1LASEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 13:04:08 -0500
In-Reply-To: <20111201092950.00006ce8@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Thu, 1 Dec 2011 09:29:50 -0800

> Tom, thanks very much for finding this subtle bug!  I bet that this
> commit (which I had missed) broke a lot of other drivers in
> very subtle ways due to changing a long standing behavior.

I call bullshit on this.

It's always been possible, any entity between the TCP stack and your
driver can pull data from the segmented pages into the linear data
area.

F.e. netfilter, packet scheduler actions, you name it.

This code sequence has always been buggy.
