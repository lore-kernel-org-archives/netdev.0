From: Yavor Goulishev <yavor@simplifymedia.com>
Subject: RE: [Patch] Establishing more than 64K outgoing TCP connections
Date: Fri, 7 Nov 2008 01:57:34 -0500
Message-ID: <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887B@MBX73.ad2.softcom.biz>
References: <241CE5A1B2AFFA4987A663380D74C0BB3FD69B08A7@MBX73.ad2.softcom.biz>
	<20081101.211541.182428064.davem@davemloft.net>
	<241CE5A1B2AFFA4987A663380D74C0BB3FFD158878@MBX73.ad2.softcom.biz>,<20081106.222323.230548519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xsmtp03.mail2web.com ([168.144.250.223]:42178 "EHLO
	xsmtp03.mail2web.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbYKGG61 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 01:58:27 -0500
In-Reply-To: <20081106.222323.230548519.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm suggesting a solution different from my original patch.
To overcome the limit and preserver the current properties you can
just change the hash function and the the table size.
This is just an idea.

The current hash is only the port number.
Not sure why you want linear access in a hash table though:
  >  I'm asking for O(num_ports_bound / hash_table_size) access.
What is this? Searching for unused port number?
It would stay the same if you use "(port + ip) % size".

--Yavor
________________________________________
From: David Miller [davem@davemloft.net]
Sent: Thursday, November 06, 2008 10:23 PM
To: Yavor Goulishev
Cc: netdev@vger.kernel.org
Subject: Re: [Patch] Establishing more than 64K outgoing TCP connections

From: Yavor Goulishev <yavor@simplifymedia.com>
Date: Fri, 7 Nov 2008 01:12:36 -0500

> I see that you want to access the hash table in O(1)  and
> you try to get a port number at empty bucket. This is clever.
> However having hash table size 65536 and hash function just the port number can
> work only for 64K binds, right? If I need more they need to go in the chains.
>
> So may be having a better hash function and configurable table size (/proc/sys/net/...)
> can work without limitation and with good performance.
> For example:
>     hash_fn = (port + local_ip) % size

All you have to preserve is that the hash distribution is evenly
spread.  That is what your patch violated.  I'm not asking for O(1)
access, I'm asking for O(num_ports_bound / hash_table_size) access.

Trying to solve all other kinds of issues just distracts from the
core issue.
