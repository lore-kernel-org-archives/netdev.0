From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net-gre-gro: Fix a bug that breaks the forwarding path
Date: Thu, 6 Mar 2014 17:30:01 +0100
Message-ID: <20140306163001.GA3092@order.stressinduktion.org>
References: <1393536377-32243-1-git-send-email-hkchu@google.com> <CAJZOPZKy7w-q5+pp=FgCs8LdQL6e16zAiJr89VMkh+h7obAArg@mail.gmail.com> <CAPshTCgLo8ycMTtoa+D14+7pPxJaiC-jUzyR3PJcrMKFw9V0zA@mail.gmail.com> <20140228.165614.1112789771887381245.davem@davemloft.net> <5315FBAA.3030809@mellanox.com> <alpine.LFD.2.03.1403041359350.7122@intel.com> <CA+mtBx9i1tOTzgjCfoxXjzjkJyFWCoQDYdvQAejWXketUf8VYQ@mail.gmail.com> <CAJZOPZKoUm_uAc_8r14oF08C2+f_-tp33rLv6bG=_2n4=KaF7Q@mail.gmail.com> <alpine.LFD.2.03.1403060841260.2472@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jerry Chu <hkchu@google.com>,
	David Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45719 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015AbaCFQaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 11:30:03 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.03.1403060841260.2472@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2014 at 08:42:32AM -0800, Joseph Gasparakis wrote:
> 
> 
> On Wed, 5 Mar 2014, Or Gerlitz wrote:
> 
> > On Wed, Mar 5, 2014 at 2:50 AM, Tom Herbert <therbert@google.com> wrote:
> > > I am concerned that we are overloading the skb->encpasulation
> > 
> > Guys, so to sum up yesterday's messages on this thread -- do folks
> > think we can come up with better/proper definition for the
> > skb->encapsulation bit, or we have to make this multiple bits, or we
> > have (hopefully not too non linear) dependancy on proper
> > definitions/usage of the skb->ip_summed field?
> > 
> > 
> > Or.
> >
> 
> From my perspective I do not see a gap with the mentioned fields, but I am 
> open if anyone has something to suggest.

I am still unsure if we want to deal with segmentation in nested tunnels. In
that case I fear we would need additional markers when to actual segment the
UDP packet and update the fragments.

This came up in commit 91a48a2e85a3b7 ("ipv4: ipv6: better estimate tunnel
header cut for correct ufo handling").

Greetings,

  Hannes
