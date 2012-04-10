From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Tue, 10 Apr 2012 12:04:19 +0200
Message-ID: <1334052259.3126.68.camel@edumazet-glaptop>
References: <20120408171323.GA16012@redhat.com>
	 <1334044558.3126.5.camel@edumazet-glaptop>
	 <20120410084151.GA27193@redhat.com>
	 <1334048100.3126.21.camel@edumazet-glaptop>
	 <20120410093140.GA27651@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jason Wang <jasowang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120410093140.GA27651@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-04-10 at 12:31 +0300, Michael S. Tsirkin wrote:

> True. Still this is the only interface we have for controlling
> the internal queue length so it seems safe to assume someone
> is using it for this purpose.
> 

So to workaround a problem in tun, you want to hack net/core/dev.c :(

Packets in qdisc should not be orphaned.

If you think about it, why do we attach skb to socket in the first
place ?

If its not needed for tun, why should it be needed for other devices ?

If TUN has a problem being stopped forever, maybe it should take
appropriate action to flush all packets in qdisc queue after a while, as
this makes no sense to delay packets forever.
