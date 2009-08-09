From: Phil Sutter <n0-1@freewrt.org>
Subject: Re: [PATCH] korina: Read buffer overflow
Date: Sun,  9 Aug 2009 02:06:25 +0200
Message-ID: <20090809000640.216D44CEAA@orbit.nwl.cc>
References: <20090808164512.02C174CEAA@orbit.nwl.cc>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, florian@openwrt.org,
	Roel Kluin <roel.kluin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:50329 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753321AbZHIAGj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Aug 2009 20:06:39 -0400
In-Reply-To: <20090808164512.02C174CEAA@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

Testing of my approach to solve the buffer overrun issue showed that
living with a subset of the requested receive descriptors is not as easy
as initially assumed: uppon allocation failure the number of descriptors
would have to be reduced to the next lower power of two (as also stated
in the corresponding define's comment), which I consider too much
overhead. A better solution would be to export the ring parameters via
ethtool. For now, let's go Roel's way aborting completely and cleaning
up in this case.

The following series fixes the incorrect printk formatting we already
discussed, implements the solution from above and makes the driver use
netdev_ops.

Greetings, Phil
