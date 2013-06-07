From: Jonas Gorski <jogo@openwrt.org>
Subject: Re: [RFC] ipv6: allow rejecting with "source address failed policy"
Date: Sat, 8 Jun 2013 00:40:00 +0200
Message-ID: <20130608004000.00007ce8@unknown>
References: <1370270708-24398-1-git-send-email-jogo@openwrt.org>
	<20130607.152730.1116898639369296832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nanl.de ([217.115.11.12]:40619 "EHLO mail.nanl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756018Ab3FGWkH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jun 2013 18:40:07 -0400
In-Reply-To: <20130607.152730.1116898639369296832.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 07 Jun 2013 15:27:30 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Jonas Gorski <jogo@openwrt.org>
> Date: Mon,  3 Jun 2013 16:45:08 +0200
> 
> > RFC6204 L-14 requires rejecting traffic from invalid addresses with
> > ICMPv6 Destination Unreachable, Code 5 (Source address failed
> > ingress/ egress policy) on the LAN side, so add an appropriate rule
> > for that.
> > 
> > Signed-off-by: Jonas Gorski <jogo@openwrt.org>
> 
> I don't see the point of this, there is no difference from the
> existing PROHIBIT other than the error code.  Everything that needs to
> be expressed can be done using PROHIBIT.
> 

There is a semantic difference. PROHIBIT says the *destination*
address is not allowed, so trying again is pointless.

This one says the while the destination is allowed, the *source*
address is not allowed, and a different source address should be used.
So probably -EAGAIN would be the right error code in that case.
"POLICY_FAILED" is maybe a wrong abbreviation, but the full name is
quite long (I'm open for suggestions).

Of course maybe handling of this kind of message should be added, too;
which should trigger the source address selection to chose a different
one.

Unless you say I can change the ICMPv6 Destination Unreached Code used
through appropriate rules, then this might be redundant.


Regards
Jonas
