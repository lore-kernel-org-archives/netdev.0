From: Patrick McHardy <kaber@trash.net>
Subject: Re: RFC: net: allow to propagate errors through	->ndo_hard_start_xmit()
Date: Tue, 10 Nov 2009 12:04:47 +0100
Message-ID: <4AF948CF.90804@trash.net>
References: <4AF87070.6020007@trash.net> <20091109195000.GA10325@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64427 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbZKJLEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 06:04:51 -0500
In-Reply-To: <20091109195000.GA10325@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Nov 09, 2009 at 08:41:36PM +0100, Patrick McHardy wrote:
>> - I'm not sure the error handling in dev_hard_start_xmit() for GSO
>>   skbs is optimal. When the driver returns an error, it is assumed
>>   the current segment has been freed. The patch then frees the
>>   entire GSO skb, including all remaining segments. Alternatively
>>   it could try to transmit the remaining segments later.
> 
> Well driver errors (not queueing errors) should never happen.

Yeah, usually there will only be queueing errors. One case for
a non-queueing error might be to return EHOSTUNREACH from ipip
or gre when there's no route to the peer.

> And if they do then they're likely to persist.  So freeing the
> rest should be sufficient, unless of course if doing it some
> other way is simpler :)

This way seems simpler. Thanks.
