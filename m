From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skb_pull_rcsum - Fatal exception in interrupt
Date: Mon, 20 Aug 2007 22:24:14 +0800
Message-ID: <E1IN8Aw-0003mu-00@gondolin.me.apana.org.au>
References: <20070815155431.GA28761@2ka.mipt.ru>
Cc: alan@wylie.me.uk, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru (Evgeniy Polyakov)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4320 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757235AbXHTOYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 10:24:18 -0400
In-Reply-To: <20070815155431.GA28761@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> Actually if dmesg will show that there is something in fragments, it
> should use pskb_may_pull(). The same bug exist in bridge and vlan, btw,
> so it might be a solution to remove bug_on from skb_pull_rcsum() and
> instead call may_pull?

That would be too easy :) As was the case here, the data pulled
has already been accessed so calling pskb_may_pull in the pulling
function is too late.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
