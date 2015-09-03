From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] Revert "net/ipv6: add sysctl option
 accept_ra_min_hop_limit"
Date: Thu, 3 Sep 2015 10:39:53 +0200
Message-ID: <20150903083953.GA6328@breakpoint.cc>
References: <20150902094301.GA6434@via.ecp.fr>
 <20150902.161110.223512323094619164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sd@queasysnail.net, netdev@vger.kernel.org, liuhangbin@gmail.com,
	hideaki.yoshifuji@miraclelinux.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40945 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751289AbbICIj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 04:39:56 -0400
Content-Disposition: inline
In-Reply-To: <20150902.161110.223512323094619164.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Sabrina Dubroca <sd@queasysnail.net>
> Date: Wed, 2 Sep 2015 11:43:01 +0200
> 
> > This reverts commit 8013d1d7eafb0589ca766db6b74026f76b7f5cb4.
> > 
> > There are several issues with this patch.
> > It completely cancels the security changes introduced by 6fd99094de2b
> > ("ipv6: Don't reduce hop limit for an interface").
> > The current default value (min hop limit = 1) can result in the same
> > denial of service that 6fd99094de2b prevents, but it is hard to define
> > a correct and sane default value.
> > More generally, it is yet another IPv6 sysctl, and we already have too
> > many.
> > 
> > This was introduced to satisfy a TAHI test case which, in my opinion, is
> > too strict, turning the RFC's "SHOULD" into a "MUST":
> > 
> >     If the received Cur Hop Limit value is non-zero, the host
> >     SHOULD set its CurHopLimit variable to the received value.
> > 
> > The behavior of this sysctl is wrong in multiple ways.  Some are
> > fixable, but let's not rush this commit into mainline, and revert this
> > while we still can, then we can come up with a better solution.
> > 
> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> 
> I don't agree with this revert.
> 
> If you look at the original commit, the quoted RFC recommends adding
> a configurable method to protect against this.

Which also means it recommends a configurable method to NOT protect
against this.

Which begs the question in which scenario you would want to configure
end hosts in such a way that an RA can shrink hoplimit to values
where machines can't talk to internet hosts anymore.

> The only thing I would entertain is potentially an adjustment of the
> default, working in concert with the TAHI folks to make sure their
> tests still pass with any new default.

So, assuming we would change the default to 64 (the hoplimit default).
Where would it make sense to reconfigure this to a lower value?

Moreover, if we would (hypothetically) assume that an administrator wants
a smaller hop limit value and has to change knob to allow e.g. min
hoplimit of 10 they might as well just change the default hoplimit value
rather than altering min hoplimit and then set it via RA...?
