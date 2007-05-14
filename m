From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: Problem with xfrm (ipsec) as state/spi selected solely on outer ip addresses
Date: Mon, 14 May 2007 11:00:21 +0300
Message-ID: <200705141100.21424.joakim.koskela@hiit.fi>
References: <200705111622.24680.joakim.koskela@hiit.fi> <46449635.3050206@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:59336 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753075AbXENIAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 04:00:09 -0400
In-Reply-To: <46449635.3050206@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 11 May 2007 19:13:41 Patrick McHardy wrote:
> Joakim Koskela wrote:
> > I'm running a system where there might be multiple simultenously
> > active ipsec states between two hosts (ipv6, but guess it applies to
> > v4 as well) where the outer ip is the same for all states, but the
> > inner differ (using beet mode).
> >
> > The problem is that after establishing these states, it seems that the
> > one associated with outgoing traffic is selected solely by the outer
> > address (the first state matching the outer ip-pairs is used), which
> > usually results in the wrong spi and the packet being dropped at the
> > receiver.
>
> This should only pick states matching the flow:
>
> if (x->km.state == XFRM_STATE_VALID) {
>
>
>         if (!xfrm_selector_match(&x->sel, fl, family) ||
>             !security_xfrm_state_pol_flow_match(x, pol, fl))
>                 continue;
> ...
>
> I'm probably misunderstanding your configuration, could you post the
> SA selectors and addresses that result in an incorrect state being
> picked?
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Oh, your right. I wasn't setting the netmask correctly (zero) for the 
selectors, making them match anything. Sorry for the waste of time!

br, j

-- 
Joakim Koskela
Helsinki Institute for Information Technology (HIIT)
