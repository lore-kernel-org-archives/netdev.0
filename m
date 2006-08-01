From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help()
	2.6.18-rc3
Date: Tue, 01 Aug 2006 08:55:18 -0400
Message-ID: <1154436918.5170.125.camel@jzny2>
References: <44CE4DCA.8000609@trash.net> <44CF0086.1030404@trash.net>
	 <20060801072358.GB3802@gondor.apana.org.au>
	 <20060801.003614.54188740.davem@davemloft.net>
	 <20060801074504.GA4272@gondor.apana.org.au>
	 <1154433648.5170.84.camel@jzny2>
	 <20060801123408.GB6177@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:26821 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751591AbWHAMzY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 08:55:24 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G7tmQ-00070m-3V
	for netdev@vger.kernel.org; Tue, 01 Aug 2006 08:55:26 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060801123408.GB6177@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-01-08 at 22:34 +1000, Herbert Xu wrote:

> What I'd like to know is do we really need to preserve
> 
> 	tc_verd/tc_index/input_dev
> 
> for a packet crossing loopback's xmit function?
> 

My instinctive reaction is to say no. Heres a (slightly complex)
example:

--> eth0(GSO ON) ---> lo --> eth1(GSO off) --> eth3(GSO ON)

When we get to lo in the above graph, input_dev=eth0 and when we leave
that info will be overwritten to be input_dev=lo. 

I just added the GSO markers (incase that info is useful) to show that
we could move in the same topology between GSO and non-GSO devices.

I believe it would be fine for lo not to preserve. Not sure if it is ok
as a general rule though. 

cheers,
jamal

