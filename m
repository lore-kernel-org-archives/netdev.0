From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 07:23:03 +0200
Message-ID: <201206270723.11615.hans.schillstrom@ericsson.com>
References: <1340440962.17495.39.camel@edumazet-glaptop> <201206260734.33472.hans.schillstrom@ericsson.com> <1340730156.10893.359.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "subramanian.vijay@gmail.com" <subramanian.vijay@gmail.com>,
	"dave.taht@gmail.com" <dave.taht@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ncardwell@google.com" <ncardwell@google.com>,
	"therbert@google.com" <therbert@google.com>,
	"brouer@redhat.com" <brouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:58605 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994Ab2F0FXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:23:24 -0400
In-Reply-To: <1340730156.10893.359.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 26 June 2012 19:02:36 Eric Dumazet wrote:
> On Tue, 2012-06-26 at 07:34 +0200, Hans Schillstrom wrote:
> 
> > This patch didn't give much in gain actually.
> 
> With a 100Mbps link it does.
 
I was testing with a patched igb driver with TCP SYN irq:s on one core only,
there was some fault in the prev. setup (RPS was also involved) because now it gives a boost of ~15%

> With a 1Gbps link we are cpu bounded for sure.

True.

> 
> > The big cycle consumer during a syn attack is SHA sum right now, 
> > so from that perspective it's better to add aes crypto (by using AES-NI) 
> > to the syn cookies instead of SHA sum. Even if only newer x86_64 can use it.
> 
> My dev machine is able to process ~280.000 SYN (and synack) per second
> (tg3, mono queue), and sha_transform() takes ~10 % of the time according
> to perf.

My test machine is not that fast :-(
I have only 170.000 syn/synack per sec. and sha_transform() takes ~9.6%
have seen peeks of 16% (during 10 sec samples)

> 
> With David patch using jhash instead of SHA, I reach ~315.000 SYN per
> second.

I have similar results from ~170k to ~199k synack/sec.

BTW, 
cookie_hash() did not show up in the perf results, (< 0.08%)
