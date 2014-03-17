From: David Miller <davem@davemloft.net>
Subject: Re: mlx4 netpoll and rx/tx weirdness
Date: Mon, 17 Mar 2014 17:22:30 -0400 (EDT)
Message-ID: <20140317.172230.76193310497948256.davem@davemloft.net>
References: <20140315.122912.1621610280186900725.davem@davemloft.net>
	<87ob17kz96.fsf_-_@xmission.com>
	<1394986621.9668.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, ben@decadent.org.uk, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	amirv@mellanox.com, ogerlitz@mellanox.com, jackm@dev.mellanox.co.il
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43333 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbaCQVWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 17:22:32 -0400
In-Reply-To: <1394986621.9668.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 16 Mar 2014 09:17:01 -0700

> Wait a minute, I thought ndo_poll_controller() had to be synchronous,
> not schedule a napi ?

ndo_poll_controller() basically runs the hardware interrupt handler,
which might schedule NAPI processing.  Then netpoll invokes
the NAPI poll in whatever state ndo_poll_controller() left it in.
