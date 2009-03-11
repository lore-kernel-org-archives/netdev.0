From: Marian =?utf-8?B?xI51cmtvdmnEjQ==?= <md@bts.sk>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Wed, 11 Mar 2009 10:05:46 +0100
Message-ID: <20090311090546.GA22086@bts.sk>
References: <20090310160040.GA93054@bts.sk> <20090310.091816.178102814.davem@davemloft.net> <20090311082920.GA20543@bts.sk> <20090311.014103.163410266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from saus.bts.sk ([194.160.23.4]:60976 "EHLO saus.bts.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752530AbZCKJFt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2009 05:05:49 -0400
Content-Disposition: inline
In-Reply-To: <20090311.014103.163410266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Let me clue you in about something you may not be aware of.
> 
> If you don't auto-tune and let the RX socket buffer increase up
> to a few megabytes, you cannot fully utilize the link on real
> trans-continental connections people are using over the internet
> today.
> 
> So your suggestion would be a huge step backwards.

Are you kidding or treating anyone else but you a complete idiot?
I never said autotuning should be disabled !

What I proposed is to limit the maximum autotuned buffer size to:
 
NIC full bandwidth * RTT measured during initial phase of TCP connection

This would for 100 Mbps connection become:

at RTT 5 msec 64 kB
at RTT 50 msec 640 kB
at RTT 200 msec 2,56 MB

With 1 Gbps connection this will become:

at RTT 5 msec 640 kB
at RTT 50 msec 6,4 MB
at RTT 200 msec 25,6 MB (if your hardlimit is that big).

In fact this will IMHO work much better than today, since you'll be able
to use even larger hardlimits (not 4 MB but e.g. 16 MB if you wish) and
still be protected from overflowing all buffers at your LAN or any other
low RTT paths.

> So the world is much bigger than your little university where you've
> decided to oversubscribe your network, and there are many other issues
> to consider besides your specific localized problem.

Please spare such junk for yourself and please start talking about technical
matters.

