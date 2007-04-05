From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec PMTUD problem
Date: Thu, 5 Apr 2007 22:04:25 +1000
Message-ID: <20070405120425.GC10972@gondor.apana.org.au>
References: <46110ED1.9070209@trash.net> <20070403095510.GA7754@gondor.apana.org.au> <46128187.4090601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4416 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1766988AbXDEN4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 09:56:20 -0400
Content-Disposition: inline
In-Reply-To: <46128187.4090601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 03, 2007 at 06:32:07PM +0200, Patrick McHardy wrote:
> 
> I'm not sure I understand how this would work, the ICMP message
> looks the same in both cases. Or are you suggesting to
> differentiate based on the source of the ICMP message?

Actually you're right, this can't work in the general case.  Even
if we had real devices for IPsec tunnels, there is still no way to
reliably figure out which device we should attribute a given MTU
event to if the same address appears on more than one device.

> Yes, that would work as a workaround, but it still seems like
> something worth fixing.

One possible solution is to not send MTU errors to ourselves since
we it wouldn't give us any new information.  We'd need to audit the
users of icmp_send to make sure that there isn't a legitimate case
where we'd want to do that.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
