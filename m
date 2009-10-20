From: Atis Elsts <atis@mikrotik.com>
Subject: Re: Policy routing + route "via" gives a strange behavior
Date: Tue, 20 Oct 2009 19:48:39 +0300
Message-ID: <200910201948.39778.atis@mikrotik.com>
References: <20091020132820.GA3159@gg.studio.tixteam.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Guido Trotter <ultrotter@quaqua.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bute.mt.lv ([159.148.172.196]:41789 "EHLO bute.mt.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751855AbZJTQrS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2009 12:47:18 -0400
In-Reply-To: <20091020132820.GA3159@gg.studio.tixteam.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 20 October 2009 16:28:20 you wrote:
> This is also refused unless a route like the one before appears in the
> default table, even though it does appear in table 100. Is this the right
> behavior, and if yes, why? 

I guess what you describe is too infrequent use case for anyone to really 
care. Connected and link scoped routes are usually not added to policy 
routing tables :) Can you explain more for what kind of setup this is needed?

This "issue" could be solved by using routing table in the FIB lookup done in 
fib_check_nh(). However, doing that would break a lot more setups than it 
would "fix".
For example, if you had these rules
  from all to 1.2.3.4 fwmark 0x64 lookup 100
  from all fwmark 0x64 unreachable
then adding policy route to table 100 would fail unless nexthop 1.2.3.4 was 
used...

Anyway, you can achieve what you wish by using the "onlink" option, e.g.:
  ip route add table 100 default dev eth1 via 192.168.5.254 onlink

Atis
