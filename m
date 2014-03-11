From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] bonding: Call dev_kfree_skby_any instead of
 kfree_skb.
Date: Tue, 11 Mar 2014 12:39:01 -0400 (EDT)
Message-ID: <20140311.123901.1984947447632413268.davem@davemloft.net>
References: <1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311.004217.1616529960369263682.davem@davemloft.net>
	<1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558AbaCKQjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 12:39:05 -0400
In-Reply-To: <1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Mar 2014 22:02:38 -0700

> It seems netpoll should not drain rx queues.

There are netpoll users (admittedly, out of tree) that make use of
packet receive.

kdump is one.

That's what all of the __netpoll_rx() et al. stuff is for.

Therefore we'll probably just have to enforce that if a netpoll
user wants RX packets, he has to invoke netpoll from a reasonable
context.

But if we're called from hardware interrupts, yes we block RX
processing.
