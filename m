From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] Establishing more than 64K outgoing TCP connections
Date: Thu, 06 Nov 2008 22:23:23 -0800 (PST)
Message-ID: <20081106.222323.230548519.davem@davemloft.net>
References: <241CE5A1B2AFFA4987A663380D74C0BB3FD69B08A7@MBX73.ad2.softcom.biz>
	<20081101.211541.182428064.davem@davemloft.net>
	<241CE5A1B2AFFA4987A663380D74C0BB3FFD158878@MBX73.ad2.softcom.biz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yavor@simplifymedia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33043
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750898AbYKGGXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 01:23:24 -0500
In-Reply-To: <241CE5A1B2AFFA4987A663380D74C0BB3FFD158878@MBX73.ad2.softcom.biz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
