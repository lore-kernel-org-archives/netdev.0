From: Yavor Goulishev <yavor@simplifymedia.com>
Subject: RE: [Patch] Establishing more than 64K outgoing TCP connections
Date: Fri, 7 Nov 2008 11:38:14 -0500
Message-ID: <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887F@MBX73.ad2.softcom.biz>
References: <241CE5A1B2AFFA4987A663380D74C0BB3FD69B08A7@MBX73.ad2.softcom.biz>
 <20081101.211541.182428064.davem@davemloft.net>
 <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887B@MBX73.ad2.softcom.biz>,<20081107084555.GA13347@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xsmtp08.mail2web.com ([168.144.250.208]:33962 "EHLO
	xsmtp08.mail2web.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347AbYKGQkh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 11:40:37 -0500
In-Reply-To: <20081107084555.GA13347@ioremap.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


________________________________________
From: Evgeniy Polyakov [zbr@ioremap.net]
Sent: Friday, November 07, 2008 12:45 AM
To: Yavor Goulishev
Cc: David Miller; netdev@vger.kernel.org
Subject: Re: [Patch] Establishing more than 64K outgoing TCP connections

> When sockets (hash results) are evenly distributed over the hash table,
> access will be O(num_of_elemets / hash_table_size), with particulary big
> table it will be O(1).
OK, but this is mainly achieved with good hash function and proper table size.
My original patch wouldn't change the locations(buckets) of the ports. It will just chose different ports.
The hack for picking a good port number just looks for empty bucket.

> If you will add any other fields into hash in inet_csk_get_port(), this
> will not change anything, since it will just switch hash table bucket to
> be checked. When we found hash bucket for given port, all its entries
> are checked to have the same parameters as in provided data. See how
> bind_conflict() callback is invoked in inet_csk_get_port().

It would change. Switching the bucket allows you to grow the table size and keep O(1).
Without changing the hash function, growing the table size will not help.
Currently all binds on the same port will go to the same bucket.

--Yavor
