From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] Revert "net/ipv6: add sysctl option
 accept_ra_min_hop_limit"
Date: Fri, 11 Sep 2015 12:53:00 +0200
Message-ID: <20150911105300.GJ24810@breakpoint.cc>
References: <20150902094301.GA6434@via.ecp.fr>
 <20150902.161110.223512323094619164.davem@davemloft.net>
 <20150909101054.GA6753@bistromath.redhat.com>
 <55F11AAD.3030209@miraclelinux.com>
 <20150910094037.GB22575@bistromath.redhat.com>
 <55F245B8.3060903@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sabrina Dubroca <sd@queasysnail.net>,
	David Miller <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	liuhangbin@gmail.com, ljungmark@modio.se,
	hannes@stressinduktion.org
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56760 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751932AbbIKKxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 06:53:05 -0400
Content-Disposition: inline
In-Reply-To: <55F245B8.3060903@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com> wrote:
> Sabrina Dubroca wrote:
> > 2015-09-10, 14:52:45 +0900, YOSHIFUJI Hideaki wrote:
> >> Sabrina Dubroca wrote:
> >>> Would you agree with a default of 64, as Florian suggested?
> >>
> >> 1 was chosen to restore our behavior before introduction of current
> >> hoplimit check.  I am not in favor of changing that value.
> > 
> > But our old behavior had a security issue, which is why the >= current
> > check was introduced.
> 
> We have the knob to "protect" ourselves now but it has drawbacks no to
> accept lower values than specified.  We can never have ultimate default
> for everybody.  The knob might "mitigate" the issue but once we have
> any rouge routers on our L2, we lose anyway.  So, I do want to keep it
> as-is not to change our traditional behavior.

If that argument is brough forward (and it's a good point!), then the
entire case for rejecting 'low' hoplimit values in first place becomes moot.

If this is an important security issue, then either the sysctl has to be
removed or the default raised to some 'safe' value (32, for example).

If its not a security issue -- and it isn't if we think "1" is a good
default choice -- then we should seriously consider reverting both
the added sysctl and the 'original' commit (6fd99094de2b; "ipv6: Don't
reduce hop limit for an interface").

Cheers,
Florian
