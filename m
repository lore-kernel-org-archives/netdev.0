From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 09:48:24 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908250946520.5972@gentwo.org>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
 <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171848370.15956@gentwo.org>  <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908241334230.30487@gentwo.org>  <4A930DEF.5000008@gmail.com>
 <1251153361.29173.25.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.ultrahosting.com ([74.213.175.253]:54528 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750734AbZHYNs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 09:48:26 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6586582CEE2
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 09:49:21 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id UjaOYzQfAT7W for <netdev@vger.kernel.org>;
	Tue, 25 Aug 2009 09:49:21 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A765782CEE8
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 09:49:16 -0400 (EDT)
In-Reply-To: <1251153361.29173.25.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Aug 2009, Sridhar Samudrala wrote:

> So are you hitting this case with your workload and does this account for all the
> packet losses you are seeing?

Yes.

> If we are dropping the packet and returing NET_XMIT_DROP, should
> we also increment qdisc drop stats (sch->qstats.drops)?

I think so but I am no expert. I was surprised to not even see counter
increments at that level. But I was content to fix up the higher level
tracking to have at least one counter that showed the packet loss.

> If we count these drops as qdisc drops, should we also count them as IP OUTDISCARDS?

Yes.

