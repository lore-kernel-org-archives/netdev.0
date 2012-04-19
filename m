From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid expensive pskb_expand_head()
 calls
Date: Thu, 19 Apr 2012 15:52:07 +0200
Message-ID: <1334843527.2395.182.camel@edumazet-glaptop>
References: <1334653608.6226.11.camel@edumazet-laptop>
	 <1334654187.2696.2.camel@jtkirshe-mobl> <4F8D93E1.9090000@intel.com>
	 <1334681204.2472.41.camel@edumazet-glaptop>
	 <1334698722.2472.71.camel@edumazet-glaptop>
	 <1334764184.2472.299.camel@edumazet-glaptop>
	 <CADVnQy=BkhSBHyN2hyBy=_H64oM8sJvyZZfEjK1x7PYzoLv=5w@mail.gmail.com>
	 <1334776707.2472.316.camel@edumazet-glaptop>
	 <1334778707.2472.333.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1204191401240.735@wel-95.cs.helsinki.fi>
	 <1334835018.2395.66.camel@edumazet-glaptop>
	 <1334841481.2395.175.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:55716 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754253Ab2DSNwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 09:52:13 -0400
Received: by bkcik5 with SMTP id ik5so6380662bkc.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 06:52:12 -0700 (PDT)
In-Reply-To: <1334841481.2395.175.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-19 at 15:18 +0200, Eric Dumazet wrote:
> On Thu, 2012-04-19 at 13:30 +0200, Eric Dumazet wrote:
> 
> > I'll provide a v3 anyway with more performance data, I setup two cards
> > in PCI x8 slots to get full bandwidth.
> 
> Incidentally, using PCI x8 slots dont anymore trigger the slow path on
> unpatched kernel and a single flow (~9410 Mbits)
> 
> It seems we are lucky enough to TX complete sent clones before trying to
> tcp_trim_head() when processing ACK
> 
> Sounds like a timing issue, and fact that drivers batches TX completions
> and RX completions.
> 
> Also BQL might have changed things a bit here (ixgbe is BQL enabled)
> 
> Only if I start several concurrent flows I see the pskb_expand_head()
> overhead.
> 
> 

And disabling GRO on receiver definitely demonstrates the problem, even
with a single flow. (and performance drops from 9410 Mbit to 6050 Mbit)
