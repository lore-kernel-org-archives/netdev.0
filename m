From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPsec PMTUD problem
Date: Thu, 05 Apr 2007 14:09:20 +0200
Message-ID: <4614E6F0.10905@trash.net>
References: <46110ED1.9070209@trash.net> <20070403095510.GA7754@gondor.apana.org.au> <46128187.4090601@trash.net> <20070405120425.GC10972@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49679 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992511AbXDEMJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 08:09:26 -0400
In-Reply-To: <20070405120425.GC10972@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Tue, Apr 03, 2007 at 06:32:07PM +0200, Patrick McHardy wrote:
> 
>>I'm not sure I understand how this would work, the ICMP message
>>looks the same in both cases. Or are you suggesting to
>>differentiate based on the source of the ICMP message?
> 
> 
> Actually you're right, this can't work in the general case.  Even
> if we had real devices for IPsec tunnels, there is still no way to
> reliably figure out which device we should attribute a given MTU
> event to if the same address appears on more than one device.
> 
> 
>>Yes, that would work as a workaround, but it still seems like
>>something worth fixing.
> 
> 
> One possible solution is to not send MTU errors to ourselves since
> we it wouldn't give us any new information.  We'd need to audit the
> users of icmp_send to make sure that there isn't a legitimate case
> where we'd want to do that.


One such case is delivery of errors to sockets. We'd need to make
sure the errors are delivered some other way.
