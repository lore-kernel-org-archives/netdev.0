From: David Miller <davem@davemloft.net>
Subject: Re: Netperf TCP_RR(loopback) 10% regression in 2.6.24-rc6,
 comparing with 2.6.22
Date: Mon, 21 Jan 2008 23:32:09 -0800 (PST)
Message-ID: <20080121.233209.103306410.davem@davemloft.net>
References: <1200982039.3151.120.camel@ymzhang>
	<47958CC8.9060609@cosmosbay.com>
	<1200984752.3151.261.camel@ymzhang>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, rick.jones2@hp.com, netdev@vger.kernel.org
To: yanmin_zhang@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40968
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754300AbYAVHch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 02:32:37 -0500
In-Reply-To: <1200984752.3151.261.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Tue, 22 Jan 2008 14:52:32 +0800

> I double-checked it and they are queued to socket A. If I define a
> different local port for netperf, packets will be queued to socket
> B.

This does not prove the kernel is buggy.

If netperf is binding to devices, that could make the kernel consider
the 0.0.0.0 bound socket equally preferable to the 127.0.0.1 bound
one.  When preference is equal, the first socket in the list is
choosen.

The algorithm is in net/ipv4/udp.c:__udp4_lib_lookup(), you
can look for yourself.  It uses a scoring system to decide
which socket to match.  Binding to a specific device gives
the score two points, so does binding to a specific local
address.

