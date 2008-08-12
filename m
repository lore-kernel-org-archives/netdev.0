From: Rick Jones <rick.jones2@hp.com>
Subject: Re: LRO restructuring?
Date: Mon, 11 Aug 2008 18:30:11 -0700
Message-ID: <48A0E7A3.6030200@hp.com>
References: <48A03EF9.9090602@myri.com>	<20080812005033.GA18547@gondor.apana.org.au>	<20080811.175434.215224347.davem@davemloft.net> <20080812010004.GD18547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, gallatin@myri.com,
	netdev@vger.kernel.org, brice@myri.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:26974 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbYHLBaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 21:30:14 -0400
In-Reply-To: <20080812010004.GD18547@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Aug 11, 2008 at 05:54:34PM -0700, David Miller wrote:
> 
>>And the checksums :-)  As an intermediate node we don't want
>>to touch the checksum.
> 
> 
> Yeah if it wasn't verified then we must store this as well.

Even if it was verified I think you want to keep the checksums from the 
header.   Since an intermediate device isn't supposed to be peeking at 
the TCP part anyway, it wouldn't do to drop the segment ourselves, pass 
it along to be dropped by the ultimate reciever.  And if there is 
something amis in the verification or the regeneration, we don't want to 
  introduce silent data corruption.

Likely that also goes for the IP header checksum...

rick jones
