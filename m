From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: [PATCH] net-gre-gro: Fix a bug that breaks the forwarding path
Date: Thu, 6 Mar 2014 08:42:32 -0800 (PST)
Message-ID: <alpine.LFD.2.03.1403060841260.2472@intel.com>
References: <1393536377-32243-1-git-send-email-hkchu@google.com> <CAJZOPZKy7w-q5+pp=FgCs8LdQL6e16zAiJr89VMkh+h7obAArg@mail.gmail.com> <CAPshTCgLo8ycMTtoa+D14+7pPxJaiC-jUzyR3PJcrMKFw9V0zA@mail.gmail.com> <20140228.165614.1112789771887381245.davem@davemloft.net>
 <5315FBAA.3030809@mellanox.com> <alpine.LFD.2.03.1403041359350.7122@intel.com> <CA+mtBx9i1tOTzgjCfoxXjzjkJyFWCoQDYdvQAejWXketUf8VYQ@mail.gmail.com> <CAJZOPZKoUm_uAc_8r14oF08C2+f_-tp33rLv6bG=_2n4=KaF7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Herbert <therbert@google.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	David Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55847 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751052AbaCFQY1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 11:24:27 -0500
In-Reply-To: <CAJZOPZKoUm_uAc_8r14oF08C2+f_-tp33rLv6bG=_2n4=KaF7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 5 Mar 2014, Or Gerlitz wrote:

> On Wed, Mar 5, 2014 at 2:50 AM, Tom Herbert <therbert@google.com> wrote:
> > I am concerned that we are overloading the skb->encpasulation
> 
> Guys, so to sum up yesterday's messages on this thread -- do folks
> think we can come up with better/proper definition for the
> skb->encapsulation bit, or we have to make this multiple bits, or we
> have (hopefully not too non linear) dependancy on proper
> definitions/usage of the skb->ip_summed field?
> 
> 
> Or.
>

>From my perspective I do not see a gap with the mentioned fields, but I am 
open if anyone has something to suggest.

Joseph
 
> > for instance if this is set in TX path meaning inner headers are valid,
> > this should also be true of RX. It might be better if this field
> > indicated characteristics of the packet independent of being in RX or
> > TX path. For checksum, maybe we should have a separate encap_checksum
> > field. Also, to be future proof may this should be two bits for the
> > devices that can verify checksums in multiple levels of encapsulations
> > (yes, I know this sounds absurd, but it's no more absurd than devices
> > vendors taking it upon themselves to parse to some restricted set of
> > encapsulations instead of just giving us the full packet checksum! :-)).
> 
> > I hope to have patches soon on fixing CHECKSUM_COMPLETE, I think it
> > entails some more state in skb indicating offset and extent of
> > checksum value in the packet. An like a said, we need to get out of
> > the habit of stashing pseudo csums there (unless CHECKSUM_PARTIAL is
> > set).
> >
> >> Also for Tx, skb->encapsulation should be the indication to the
> >> driver that it can use the inner headers (i.e. they are valid) in the skb
> >> in order to offload the inner csum.
> 
