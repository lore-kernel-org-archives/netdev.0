From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Mon, 06 Oct 2008 14:40:02 -0700 (PDT)
Message-ID: <20081006.144002.56418911.davem@davemloft.net>
References: <20081006185026.GA10383@minyard.local>
	<48EA8197.6080502@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: minyard@acm.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53183
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753449AbYJFVk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 17:40:27 -0400
In-Reply-To: <48EA8197.6080502@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 06 Oct 2008 23:22:31 +0200

> Me wondering what impact this synchronize_rcu() can have on mono-threaded
> VOIP applications using lot of UDP sockets. What is the maximum delay of
> this function ?

The cost is enormous, we really can't use it here.

I have a patch that did top-level socket destruction using RCU,
and that didn't use synchronize_rcu(), and that killed connection
rates by up to %20.

I can only imagine what the cost would be if I had to add such a call
in there.

Really, I can't consider these changes seriously, as-is.
