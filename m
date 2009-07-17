From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Fri, 17 Jul 2009 11:08:40 -0700 (PDT)
Message-ID: <20090717.110840.128146209.davem@davemloft.net>
References: <65634d660907141628g671812f9t4219cc8b6a493425@mail.gmail.com>
	<20090716.194846.58845712.davem@davemloft.net>
	<65634d660907171105s4989758ah533203d107924b6a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44176
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934365AbZGQSIf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2009 14:08:35 -0400
In-Reply-To: <65634d660907171105s4989758ah533203d107924b6a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Tom Herbert <therbert@google.com>
Date: Fri, 17 Jul 2009 11:05:58 -0700

> The advantage is that Toeplitz, or any reasonable device provided
> hash, allows packet steering to be done without taking any cache
> misses on the packet itself.=A0 In particular, this helps with a NIC
> that just provides Toeplitz hash (without multiQ),

Good point.

Depending upon the cache line size, however, we might have
at least the IP header in the cpu cache at this point since
eth_type_trans() had to pull in the entire ethernet header
underneath.

I totally misunderstood you, I thought you meant that with a
pure SW hash implementation, Toeplitz did better than jhash.
