From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/4] ieee802154: add generic header
 handling routines
Date: Tue, 04 Mar 2014 20:09:47 -0500 (EST)
Message-ID: <20140304.200947.355879073064420434.davem@davemloft.net>
References: <a23fcc368f1421286c1115c2365942ce.squirrel@webmail.itwm.fhg.de>
	<20140304.192309.337489223683931299.davem@davemloft.net>
	<0049a78200f573d8acc64aa879d4412c.squirrel@webmail.itwm.fhg.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39427 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754243AbaCEBJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 20:09:49 -0500
In-Reply-To: <0049a78200f573d8acc64aa879d4412c.squirrel@webmail.itwm.fhg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>
Date: Wed, 5 Mar 2014 02:01:52 +0100

> That's the thing - there are so many different byte orders floating around
> at the moment. Network byte order is little endian. Hardware addresses are
> big endian in the network layer and 6lowpan though, and our sockaddrs are
> host byte order for some parts and big endian for others. It's a real
> mess. The solution in my patch seemed the cleanest option to me.
> 
> Storing *everything* in network byte order would require a small adaption
> layer at every interaction with userspace to fix byte ordering, but that's
> doable. 6lowpan would have to do an extra byteswap for the address that I
> currently do in the header ops.

That's an odd choice, since ipv4/ipv6 universally put things in network
byte order in the sockaddrs.

But since it's been made already, you want to still use network byte
order internally in the stack.  Because you're going to process more
packets than you are going to be handling user sockaddrs.

Translate the values to network byte order on bind() etc. calls and
just be done with it.
