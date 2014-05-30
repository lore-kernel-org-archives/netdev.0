From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1 4/6] net: fec: Increase buffer descriptor entry number
Date: Fri, 30 May 2014 07:54:02 -0700
Message-ID: <1401461642.3645.104.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
	 <1401415552-2263-5-git-send-email-b38611@freescale.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1725053E@AcuExch.aculab.com>
	 <bf938381e86b4ef5b4e3cbec8733fd2e@BLUPR03MB373.namprd03.prod.outlook.com>
	 <1401455586.3645.96.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140530140137.GC783@arch.cereza>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	David Laight <David.Laight@ACULAB.COM>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: "ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:38215 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753393AbaE3OyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 10:54:04 -0400
Received: by mail-pb0-f47.google.com with SMTP id rp16so1802238pbb.6
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 07:54:03 -0700 (PDT)
In-Reply-To: <20140530140137.GC783@arch.cereza>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-30 at 11:01 -0300, ezequiel.garcia@free-electrons.com
wrote:
> Hello Eric,
> 
> On 30 May 06:13 AM, Eric Dumazet wrote:
> > On Fri, 2014-05-30 at 09:42 +0000, fugang.duan@freescale.com wrote:
> > > From: David Laight <David.Laight@ACULAB.COM> Data: Friday, May 30, 2014 5:11 PM
> > > >
> > > >Does the driver support BQL (or similar) in order to limit the amount of
> > > >queued tx traffic?
> > > >Otherwise you've significantly increased the latency for connections other
> > > >than one doing bulk tx.
> > > >
> > > >	David
> > > >
> > > The driver still don't support BQL.
> > > I will add the feature to support FEC. Thanks for your advise.
> > 
> > Note that a full size TSO packet (44 or 45 MSS) requires about 88 or 90
> > descriptors.
> > 
> 
> What's the rationale behing those numbers?
> 

64KB TSO packet, with MSS=1460 -> 44 segments  (44*1460 = 64240)
with MSS=1448 (TCP timestamps) -> 45 segments  (45*1448 = 65160)

This software TSO emulation uses at least 2 descriptors per MSS

one descriptor to hold the headers (ethernet + ip + tcp)
one descriptor (or two) to hold the payload for this MSS
