From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [3/5] [NET]: Add software TSOv4
Date: Fri, 23 Jun 2006 20:08:41 -0700
Message-ID: <1151118521.7719.0.camel@rh4>
References: <20060622081211.GA22505@gondor.apana.org.au>
 <20060622081400.GC22671@gondor.apana.org.au>
 <1151091230.6498.4.camel@rh4> <1151097976.6498.7.camel@rh4>
 <20060623233840.GA6258@gondor.apana.org.au>
 <20060623235341.GA6593@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:53514 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1750892AbWFXDHp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 23:07:45 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060623235341.GA6593@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-06-24 at 09:53 +1000, Herbert Xu wrote:

> Nevermind, I obviously complete ignored your other fix to the length of
> the last segment :) Here is a fixed version.
> 
> [NET]: Fix CHECKSUM_HW GSO problems.
> 
> Fix checksum problems in the GSO code path for CHECKSUM_HW packets.
> 
> The ipv4 TCP pseudo header checksum has to be adjusted for GSO
> segmented packets.
> 
> The adjustment is needed because the length field in the pseudo-header
> changes.  However, because we have the inequality oldlen > newlen, we
> know that delta = (u16)~oldlen + newlen is still a 16-bit quantity.
> This also means that htonl(delta) + th->check still fits in 32 bits.
> Therefore we don't have to use csum_add on this operations.
> 
> This is based on a patch by Michael Chan <mchan@broadcom.com>.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
Yes, this should work. ACK.


