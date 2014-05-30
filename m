From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH v1 4/6] net: fec: Increase buffer descriptor entry number
Date: Fri, 30 May 2014 06:13:06 -0700
Message-ID: <1401455586.3645.96.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
	 <1401415552-2263-5-git-send-email-b38611@freescale.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1725053E@AcuExch.aculab.com>
	 <bf938381e86b4ef5b4e3cbec8733fd2e@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:37993 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186AbaE3NNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 09:13:08 -0400
Received: by mail-pa0-f41.google.com with SMTP id kx10so1696299pab.14
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 06:13:07 -0700 (PDT)
In-Reply-To: <bf938381e86b4ef5b4e3cbec8733fd2e@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-30 at 09:42 +0000, fugang.duan@freescale.com wrote:
> From: David Laight <David.Laight@ACULAB.COM> Data: Friday, May 30, 2014 5:11 PM
> >
> >Does the driver support BQL (or similar) in order to limit the amount of
> >queued tx traffic?
> >Otherwise you've significantly increased the latency for connections other
> >than one doing bulk tx.
> >
> >	David
> >
> The driver still don't support BQL.
> I will add the feature to support FEC. Thanks for your advise.

Note that a full size TSO packet (44 or 45 MSS) requires about 88 or 90
descriptors.

So I do not think BQL is really needed, because a 512 slots TX ring wont
add a big latency : About 5 ms max.

BQL is generally nice for NIC supporting hardware TSO, where a 64KB TSO
packet consumes 3 or 4 descriptors.

Also note that TCP Small Queues should limit TX ring occupancy of a
single bulk flow anyway.
