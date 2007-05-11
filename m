From: Patrick McHardy <kaber@trash.net>
Subject: Re: Problem with xfrm (ipsec) as state/spi selected solely on outer
 ip addresses
Date: Fri, 11 May 2007 18:13:41 +0200
Message-ID: <46449635.3050206@trash.net>
References: <200705111622.24680.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34115 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757959AbXEKQOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 12:14:53 -0400
In-Reply-To: <200705111622.24680.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joakim Koskela wrote:
> I'm running a system where there might be multiple simultenously
> active ipsec states between two hosts (ipv6, but guess it applies to
> v4 as well) where the outer ip is the same for all states, but the
> inner differ (using beet mode).
> 
> The problem is that after establishing these states, it seems that the
> one associated with outgoing traffic is selected solely by the outer
> address (the first state matching the outer ip-pairs is used), which
> usually results in the wrong spi and the packet being dropped at the
> receiver.


This should only pick states matching the flow:

if (x->km.state == XFRM_STATE_VALID) {


        if (!xfrm_selector_match(&x->sel, fl, family) ||
            !security_xfrm_state_pol_flow_match(x, pol, fl))
                continue;
...

I'm probably misunderstanding your configuration, could you post the
SA selectors and addresses that result in an incorrect state being
picked?

