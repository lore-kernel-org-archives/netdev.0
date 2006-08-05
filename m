From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sat, 05 Aug 2006 19:36:50 -0400
Message-ID: <1154821010.5517.48.camel@jzny2>
References: <20060804101017.GA17393@gondor.apana.org.au>
	 <1154712532.3117.43.camel@rh4> <20060804110829.62136ebb@dxpl.pdx.osdl.net>
	 <20060804.163111.85390037.davem@davemloft.net>
	 <1154797002.5081.21.camel@jzny2>
	 <20060805230517.GA25468@gondor.apana.org.au>
	 <1154819868.5517.34.camel@jzny2>
	 <20060805231959.GA25768@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:20446 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932642AbWHEXhA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 19:37:00 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G9VhS-0001lo-PM
	for netdev@vger.kernel.org; Sat, 05 Aug 2006 19:36:58 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060805231959.GA25768@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-06-08 at 09:19 +1000, Herbert Xu wrote:

> Interesting.  I can't really think of why it'd do that so some extra
> checks would really help.
> 

I have to run for now but will do this tomorrow. Heres an example of
what is saw (eth devices bound to different CPUs):


on entering eth1 qdisc_is_running:

14651764 times a packet was successfully dequeued and transmitted
9379699 times we got no packet at all and exited.

no packet implies the failure of the check:
if (((skb = dev->gso_skb)) || ((skb = q->dequeue(q)))) {

I know the qlen is >= 0 otherwise i will hit the BUG().
A qlen of 0 will be interesting to find as well.

cheers,
jamal



