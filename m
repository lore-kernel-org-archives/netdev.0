From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: Re: [UDP6]: Restore sk_filter optimisation
Date: Wed, 31 Oct 2007 23:05:45 +0900
Message-ID: <20071031230545.9be711d4.mitch@linux.vnet.ibm.com>
References: <20070306012010.GA25763@gondor.apana.org.au>
	<20071029153320.d2c00f62.mitch@linux.vnet.ibm.com>
	<20071029125328.GA5453@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:60050 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754733AbXJaOJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 10:09:32 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9VE9V5A027199
	for <netdev@vger.kernel.org>; Wed, 31 Oct 2007 10:09:31 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9VE6Dfl072380
	for <netdev@vger.kernel.org>; Wed, 31 Oct 2007 08:09:26 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9VE5uJl010264
	for <netdev@vger.kernel.org>; Wed, 31 Oct 2007 08:05:57 -0600
In-Reply-To: <20071029125328.GA5453@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Oct 2007 20:53:28 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Oct 29, 2007 at 03:33:20PM +0900, Mitsuru Chinen wrote:
> > Hello Herbert,
> > 
> > Let me ask a question about this patch.
> > After this patch was applied, 2 of the protocol stack behaviors were
> > changed when it receives a UDP datagram with broken checksum:
> > 
> >  1. udp6InDatagrams is incremented instead of udpInErrors
> >  2. In userland, recvfrom() replies an error with EAGAIN.
> >     recvfrom() wasn't aware of such a packet before.
> > 
> > Are these changes intentional?
> 
> It wasn't my intention if that's what you mean :)
> 
> However, this would've happened with the old code anyway if
> someone had a filter attached so this isn't new.
>
> If it's a problem then we should just get it fixed.

As far as I tested, this doesn't happen with the old code even if
a filter is attached. However, this happen with the new code
without a filter and I don't see this rather when a filter is
attached. So, I'm afraid it's new.

By the way, could you answer the Yoshifuji-san's question?
I think the code where we should fix depends on this. 

On Mon, 29 Oct 2007 15:41:50 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> And, we're not sure how much the "optimization"'s benefit is.
> It is even worse when we are handling multicast packets.

Thank you,
----
Mitsuru Chinen <mitch@linux.vnet.ibm.com>
