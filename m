From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next, V3 0/2] net: force refragmentation for DF
 reassembed skbs
Date: Tue, 26 May 2015 16:50:07 +0200
Message-ID: <20150526145007.GF7817@breakpoint.cc>
References: <1432305171-21932-1-git-send-email-fw@strlen.de>
 <20150522.150310.2248217318352290500.davem@davemloft.net>
 <20150522192651.GA3629@breakpoint.cc>
 <1432634245.17881.57.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hannes@stressinduktion.org
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43358 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752460AbbEZOuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 10:50:12 -0400
Content-Disposition: inline
In-Reply-To: <1432634245.17881.57.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maxime Bizon <mbizon@freebox.fr> wrote:
> On Fri, 2015-05-22 at 21:26 +0200, Florian Westphal wrote:
> > But it does happen, see e.g. following bug report:
> > http://marc.info/?l=linux-netdev&m=139870308431986&w=2
> > 
> > Maxime, do you recall what type of traffic generates
> > the DF-fragments you reported?
> 
> Yep
> 
> We are an ISP and provide our own home gateway to the subscribers, which
> ends up routing traffic of a large range of end user devices.
> 
> In that case, the frag+DF traffic was seen in an exchange between a
> femtocell and a femto GW during the IPsec IKE exchange, more precisely
> on the IKE_AUTH message sent from the femto GW.

Thanks, so it seems its used to push udp frag/defrag operation to end
hosts.

> You can contact me privately if you need more details.

Its enough for me to know that this isn't random fluke, thanks.

Dave, if you disagree, one possibility would be to strip DF bit on
defrag/refrag when forwarding.

However, I think that we should respect end host "wish", i.e. reject too
big df fragment and also re-set DF on refrag so we don't conceal lower
mtu in the network.

Thanks,
Florian
