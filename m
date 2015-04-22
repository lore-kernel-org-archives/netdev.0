From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix possible deadlock in tcp_send_fin()
Date: Wed, 22 Apr 2015 14:50:14 -0400 (EDT)
Message-ID: <20150422.145014.115419919912486761.davem@davemloft.net>
References: <1429666344.18561.37.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150422.141534.1363191163633903371.davem@davemloft.net>
	<1429727967.18561.129.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johunt@akamai.com, netdev@vger.kernel.org, edumazet@google.com,
	gthelen@google.com, rientjes@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34759 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbbDVSuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 14:50:20 -0400
In-Reply-To: <1429727967.18561.129.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 22 Apr 2015 11:39:27 -0700

> Note that in the unlikely case skb can not be allocated,
> if an already transmitted packet is in the write queue, we also can OR
> the FIN flag on it, and rely on normal rtx to deliver this FIN later.
> 
> I'll cook a patch when net-next reopens.

Hmmm, we already check for something like this at the beginning of
tcp_send_fin(), I know because I added that piece of code 15+ years
ago :-)

Or are you suggesting something slightly different?
