From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Wed, 9 Apr 2014 10:10:16 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6F2E17@AcuExch.aculab.com>
References: <20140407075347.GA26461@gondor.apana.org.au>
 <E1WX4P2-0006wA-9Q@gondolin.me.apana.org.au>
 <20140408095523.2d4e14bd@nehalam.linuxnetplumber.net>
 <20140409085001.GA12938@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Herbert Xu' <herbert@gondor.apana.org.au>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:41813 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757645AbaDIKL6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 06:11:58 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 04776-07 for <netdev@vger.kernel.org>;
 Wed,  9 Apr 2014 11:11:48 +0100 (BST)
In-Reply-To: <20140409085001.GA12938@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu
...
> This patch picks the second option and moves all broadcast handling
> bar the trivial case of packets going to a single interface into
> a work queue.  Obviously there also needs to be a limit on how
> many broadcast packets we postpone in this way.  I've arbitrarily
> chosen tx_queue_len of the master device as the limit (act_mirred
> also happens to use this parameter in a similar way).
> 
> In order to ensure we don't exceed the backlog queue we will use
> netif_rx_ni instead of netif_rx for broadcast packets.

Should you limit the number of broadcasts queued for transmit
on each interface as well as the number of postponed broadcasts.

It probably isn't a good idea to completely fill an interface's
transmit queue with broadcasts.

	David
