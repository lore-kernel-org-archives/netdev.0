From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: owner-Match in 2.6.20-rc5 (fwd)
Date: Thu, 25 Jan 2007 23:14:49 +0100 (MET)
Message-ID: <Pine.LNX.4.61.0701252309200.17844@yvahk01.tjqt.qr>
References: <Pine.LNX.4.64.0701252121190.26664@blackhole.kfki.hu>
 <20070125.130111.26966608.davem@davemloft.net> <Pine.LNX.4.61.0701252206360.26335@yvahk01.tjqt.qr>
 <20070125.140149.51518685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kadlec@blackhole.kfki.hu, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tmailer.gwdg.de ([134.76.10.23]:36561 "EHLO tmailer.gwdg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030626AbXAYWQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 17:16:22 -0500
In-Reply-To: <20070125.140149.51518685.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> >> The report below was posted on the netfilter user list. Isn't there any 
>> >> ill side effect by reverting the change?
>> >
>> >Performance regression :-(
>> >
>> >This optimization saves a whole handful of heavy atomic operations in
>> >the packet transmit path of TCP.
>> >
>> >As I understand it, the owner-Match is not in the upstream tree, and
>> >it's the only thing that cares, so I see no reason to cater for it.
>> 
>> For me, it's there.
>> -rw-r--r-- 1 jengelh users 2247 Jan 25 21:37
>> /erk/kernel/linux-2.6.20-rc6/net/ipv4/netfilter/ipt_owner.c
>
>Ok, I'll see what I can do about this :-)
>

People really depend on this. Much more than than pid/comm/smpunsafe stuff.
For example, a web server [cgi enabled, etc.] which also runs squid,
to force all webtraffic through it:

-A OUTPUT -p tcp --dport 80 -m owner ! --uid-owner
  squid -j REDIRECT --to-ports 3128


	-`J'
-- 
