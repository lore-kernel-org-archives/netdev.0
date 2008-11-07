From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [Patch] Establishing more than 64K outgoing TCP connections
Date: Fri, 7 Nov 2008 11:45:55 +0300
Message-ID: <20081107084555.GA13347@ioremap.net>
References: <241CE5A1B2AFFA4987A663380D74C0BB3FD69B08A7@MBX73.ad2.softcom.biz> <20081101.211541.182428064.davem@davemloft.net> <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887B@MBX73.ad2.softcom.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yavor Goulishev <yavor@simplifymedia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netgear.net.ru ([195.178.208.66]:57594 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751007AbYKGIp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2008 03:45:57 -0500
Content-Disposition: inline
In-Reply-To: <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887B@MBX73.ad2.softcom.biz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 07, 2008 at 01:57:34AM -0500, Yavor Goulishev (yavor@simplifymedia.com) wrote:
> I'm suggesting a solution different from my original patch.
> To overcome the limit and preserver the current properties you can
> just change the hash function and the the table size.
> This is just an idea.

You can use bindtodevice and reuseaddr socket options already.

> The current hash is only the port number.
> Not sure why you want linear access in a hash table though:
>   >  I'm asking for O(num_ports_bound / hash_table_size) access.
> What is this? Searching for unused port number?
> It would stay the same if you use "(port + ip) % size".

When sockets (hash results) are evenly distributed over the hash table,
access will be O(num_of_elemets / hash_table_size), with particulary big
table it will be O(1).

If you will add any other fields into hash in inet_csk_get_port(), this
will not change anything, since it will just switch hash table bucket to
be checked. When we found hash bucket for given port, all its entries
are checked to have the same parameters as in provided data. See how
bind_conflict() callback is invoked in inet_csk_get_port().

-- 
	Evgeniy Polyakov
