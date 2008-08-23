From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/1] icmp: icmp_sk() should not use smp_processor_id() in preemptible code
Date: Sat, 23 Aug 2008 10:48:49 +1000
Message-ID: <20080823004849.GA9678@gondor.apana.org.au>
References: <20080821122040.GA2497@x200.localdomain> <1219413273-14281-1-git-send-email-den@openvz.org> <48AF4879.9070005@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Denis V. Lunev" <den@openvz.org>, davem@davemloft.net,
	adobriyan@gmail.com, netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57225 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751241AbYHWAtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 20:49:05 -0400
Content-Disposition: inline
In-Reply-To: <48AF4879.9070005@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 23, 2008 at 01:15:05AM +0200, Daniel Lezcano wrote:
>
> thanks for the fix. For my personal knowledge, why can we just use in 
> the icmp_sk function:
> 	{
> 		struct sock *isk = net->ipv4.icmp_sk[get_cpu()];
> 		put_cpu();
> 		return isk;
> 	}
> 
> ?

Because then you can get rescheduled to another CPU while still
using someone else's ICMP socket.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
