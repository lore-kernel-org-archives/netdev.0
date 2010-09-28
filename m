From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next-2.6 0/5] XFRM,IPv6: Removal of RH2/HAO from
 IPsec-protected MIPv6 traffic
Date: Tue, 28 Sep 2010 14:40:05 -0700 (PDT)
Message-ID: <20100928.144005.260072379.davem@davemloft.net>
References: <cover.1285687738.git.arno@natisbad.org>
	<20100928.133849.112575548.davem@davemloft.net>
	<87r5gdtuxv.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: arno@natisbad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58473
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753639Ab0I1Vjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 17:39:45 -0400
In-Reply-To: <87r5gdtuxv.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: arno@natisbad.org (Arnaud Ebalard)
Date: Tue, 28 Sep 2010 23:33:16 +0200

> Before following the (dumb) #ifdef path, I was about to do that but
> worried about the penalty of the additional xfrm_state_get/put_afinfo()
> calls on each packet I was about to add. Should I just reduce my amount
> of coffee or is it a valid concern?

Indeed, it is.

Even without the concern of afinfo refcounting, this test is very
heavy handed for the packet path.

Can you make it small enough that it can reasonably be inlined?
