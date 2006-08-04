From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Improve MTU estimation
Date: Fri, 04 Aug 2006 13:50:15 +0200
Message-ID: <44D33477.2060803@trash.net>
References: <44D30A48.4050403@trash.net> <44D312EF.8010202@trash.net> <20060804100121.GA17239@gondor.apana.org.au> <44D31CCE.7020301@trash.net> <20060804101345.GA17583@gondor.apana.org.au> <44D32B57.2000304@trash.net> <20060804111604.GA25693@gondor.apana.org.au> <20060804112544.GA28774@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:9431 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S932603AbWHDLwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 07:52:09 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060804112544.GA28774@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> I've reread your patches and your handling of ESP padding is spot on.
> It's anyone's guess whether the current code gets it right or not :)
> 
> However, I believe that the transport mode handling does run into
> problems with IP options.  Basically, your calculation returns a
> length that is a precise multiple of block size minus 2.
> 
> Now imagine that we have 4 bytes of IP options, given a block size
> of 8 taking away 4 bytes from inside the encrypted area simply causes
> them to be padded out so the encrypted length does not change.  However,
> we have to put those 4 bytes outside the encrypted area.  The problem is
> that we may not have those 4 bytes given the MTU.
> 
> For a standard 1500 MTU and the block size of 8 it just happens that
> we do have 4 bytes (because 1500 % 8 == 4).  However, this breaks down
> if you start with say 1480 (standard MTU for 1500 with IPIP on the
> outside).
> 
> You run into problems even with 1500 if your block size happens to be
> 16 (AES).


Now I get it, thanks :) I missed that the IP header isn't part of the
length when it is aligned. So the worst-case increases by block-size
- 4 (- 8 for IPv6). How does this look?

