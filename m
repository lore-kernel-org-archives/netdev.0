From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Tue, 8 May 2012 22:35:08 +0300
Message-ID: <20120508193507.GC28536@redhat.com>
References: <20120408171323.GA16012@redhat.com>
 <1334044558.3126.5.camel@edumazet-glaptop>
 <20120410084151.GA27193@redhat.com>
 <1334048100.3126.21.camel@edumazet-glaptop>
 <20120410093140.GA27651@redhat.com>
 <1334052259.3126.68.camel@edumazet-glaptop>
 <20120410112459.GA28825@redhat.com>
 <1334058300.3126.99.camel@edumazet-glaptop>
 <20120410124151.GA29808@redhat.com>
 <1334065929.5300.40.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jason Wang <jasowang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1983 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755917Ab2EHTfa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 15:35:30 -0400
Content-Disposition: inline
In-Reply-To: <1334065929.5300.40.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 10, 2012 at 03:52:09PM +0200, Eric Dumazet wrote:
> By the way, skb orphaning should already be done in skb_orphan_try(),
> not sure why its done again in tun_net_xmit().

Because we need to force it for skbs which have tx_flags set.

> Note we perform orphaning
> right before giving skb to device on premise it'll be sent (and freed)
> in a reasonable amount of time.

It is usually the case. I think this assumption holds for
tun normally.
