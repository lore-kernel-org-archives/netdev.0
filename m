From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: zd1211 ported to Devicescape stack
Date: Sat, 2 Dec 2006 14:25:39 +0100
Message-ID: <20061202132539.GB18326@p15091797.pureserver.info>
References: <200612020316.50965.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Luis Rodriguez <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:45050 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1424003AbWLBNZk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 08:25:40 -0500
To: Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
In-Reply-To: <200612020316.50965.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michael,

> 	I have finished a port of the zd1211 driver to the Devicescape 802.11 stack. 

This is absolutely great news. I will look into it and check it
today.

> 	- The original driver does not seem to check if a frame has been successfully 
> TXed (as in RXed an ACK), so the port does not properly report to the stack 
> whether or not a TX succeeded.

TX is atomic. Do you really want to spin for the received ACK? Layer 2 doesn't
need to make any guarantees for packet transmission, so I have
trouble to see the point here. The Linux Device Driver book says
explicitly that packet transmission must not have been completed
at the point in time the function returns.

> 	-Because d80211 does not have complete regulatory domains support yet, the 
> associated code was trimmed to the bare minimum of reading the region code. 

I have to look into it, but the code we had, didn't rely on upper
layer support. I would suggest to maintain it until d80211 has
complete regulatory domains support.

> 	- The LED link status isn't too reliable - I haven't found a way to reliably 
> tell if the upper layer thinks it is associated, and I don't know how to use 
> the LED api. Not too worried about this issue though.

It took us also some time to do it for softmac. But it appears
that the d80211 stack needs still a fair amount of work.

-- 
Uli Kunitz
