From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: use no more than one page in
 struct fw_head
Date: Mon, 17 Mar 2014 22:31:51 -0400 (EDT)
Message-ID: <20140317.223151.719003141867577870.davem@davemloft.net>
References: <20140314185917.GA18933@linux.vnet.ibm.com>
	<1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
	<1394985990.9668.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org, tgraf@suug.ch
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135AbaCRCbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 22:31:53 -0400
In-Reply-To: <1394985990.9668.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 16 Mar 2014 09:06:30 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit b4e9b520ca5d ("[NET_SCHED]: Add mask support to fwmark
> classifier") Patrick added an u32 field in fw_head, making it slightly
> bigger than one page.
> 
> Change the layout of this structure and let compiler emit a reciprocal
> divide for fw_hash(), as this makes the core more readable and
> more efficient those days.
> 
> This brings back the memory usage to a single page, and permits John
> to add a rcu_head later without any worry.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Eric let's just use an HSIZE of 256 and be done with it.

Then all of this talk of divides and cost goes out the window, as we
can assume a power of two and use simple masking.

This is basically what other classifiers in similar situations do.
