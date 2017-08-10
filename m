From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC net-next] net: xfrm: support setting an output mark.
Date: Thu, 10 Aug 2017 12:53:11 +0200
Message-ID: <20170810105311.GY2631@secunet.com>
References: <20170807092326.10239-1-lorenzo@google.com>
 <20170807111623.GQ2631@secunet.com>
 <CAKD1Yr2YXYed+vVgcyYo4XLAFXGjwwdSRucOmg+z2PVZD_A06Q@mail.gmail.com>
 <20170808075143.GR2631@secunet.com>
 <CAKD1Yr0FPo_ZAyjgFPg2CzNJiMMdUSx4PwwtL=ArPGeKHuTQ5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Nathan Harold <nharold@google.com>,
        "Jonathan Basseri" <misterikkit@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49484 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751492AbdHJKxO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Aug 2017 06:53:14 -0400
Content-Disposition: inline
In-Reply-To: <CAKD1Yr0FPo_ZAyjgFPg2CzNJiMMdUSx4PwwtL=ArPGeKHuTQ5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 10, 2017 at 02:13:15AM +0900, Lorenzo Colitti wrote:
> On Tue, Aug 8, 2017 at 4:51 PM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> > I thought you can just split the 32 bit mark into two 16 bit marks
> > by setting an appropriate mask at the xfrm and the routing mark.
> > But this has the drawback that the socket needs to know how possibly
> > tunneled packets should be routed.
> 
> Right. And if those bits are already used for something else (e.g.,
> Android uses something like 20 bits for marks) then that's not
> possible.
> 
> Also - the other approach of using the SA mark for routing the
> tunneled packet, that has backwards compatibility issues. If someone
> is using mark-based routing, and has configured an SA with a mark,
> then making the mark influence the routing lookup would change how
> those tunnels are routed and possibly break them.

Right, good point.

> 
> > So we transform the packet and may 'transform' the mark on the packet
> > too. This could make sense, but we have to point out the differences
> > between the xfrm_mark and the output_mark on the SA very explicit.
> 
> Ack. Where should this be pointed out? I've sent out a non-RFC version
> to netdev, mostly unchanged but including a fair bit more rationale in
> the commit message:
> 
> https://patchwork.ozlabs.org/patch/799891/
> 
> Or did you mean it should be be documented this in the ip-xfrm man page, or...?

A detailed commit message is what I meant, this could be also
the base for the manpage once iproute2 gets support for this.
