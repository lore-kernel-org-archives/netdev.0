From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Mon, 9 Apr 2012 07:49:51 +0800
Message-ID: <20120408234951.GA15993@gondor.apana.org.au>
References: <20120408171323.GA16012@redhat.com>
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
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120408171323.GA16012@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 08, 2012 at 08:13:25PM +0300, Michael S. Tsirkin wrote:
> commit 0110d6f22f392f976e84ab49da1b42f85b64a3c5
> tun: orphan an skb on tx
> Fixed a configuration where skbs get queued
> at the tun device forever, blocking senders.
> 
> However this fix isn't waterproof:
> userspace can control whether the interface
> is stopped, and if it is, packets
> get queued in the qdisc, again potentially forever.
> 
> Complete the fix by setting a private flag and orphaning
> at the qdisc level.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

1) Doesn't this break local UDP push-back?
2) Isn't the stall a bug in the backend and isn't this just
papering over that?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
