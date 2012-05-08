From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Tue, 8 May 2012 22:50:30 +0300
Message-ID: <20120508195029.GA29111@redhat.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1334065929.5300.40.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2012 at 03:52:09PM +0200, Eric Dumazet wrote:
> With following patch, no more qdisc on top of tun device,

I'm not sure killing qdisc is a right direction.
I think tun queue is currently oversized but I
also think we would benefit from a smart queue
management. As it is if tun user gets delayed,
stale packets accumulate in the queue and there's
no way to get rid of them without ploughing through
the backlog.

In a sense we don't really need the queue in tun at all,
the only reason we have it at all, is to make code simpler.
We could thinkably move skbs from qdisc directly to userspace.

-- 
MST
