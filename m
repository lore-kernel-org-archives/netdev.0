From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket filter
Date: Mon, 19 Nov 2007 09:09:29 +0800
Message-ID: <20071119010929.GA32651@gondor.apana.org.au>
References: <p73bq9tau2x.fsf@bingen.suse.de> <20071117.160926.232024605.davem@davemloft.net> <20071118214515.GA8161@one.firstfloor.org> <20071118.144010.236028466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, wangchen@cn.fujitsu.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2122 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752444AbXKSBK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2007 20:10:26 -0500
Content-Disposition: inline
In-Reply-To: <20071118.144010.236028466.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 18, 2007 at 02:40:10PM -0800, David Miller wrote:
>
> The networking stack DID receive the packet.  Just because a socket
> owner is busy doing something else or blocked on some other event
> is no excuse not to bump the InDataGgrams counter.

Actually if we ever implement the memory reclaim stuff for UDP
when we're short on system memory then it could be possible for
us to want to remove packets that are sitting on a socket's rcv
queue.  In that case it would be nice if InDataGrams wasn't
incremented until the app took the packet off the socket.

In any case, I just looked up RFC1213 and it says:

          udpInDatagrams OBJECT-TYPE
              SYNTAX  Counter
              ACCESS  read-only
              STATUS  mandatory
              DESCRIPTION
                      "The total number of UDP datagrams delivered to
                      UDP users."
              ::= { udp 1 }

So I think incrementing it in recvmsg is acceptable.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
