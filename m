From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH][BRIDGE-NF] Fix wrong use of skb->protocol
Date: Thu, 30 Dec 2004 23:24:15 +0100
Message-ID: <20041230222415.GB19587@xi.wantstofly.org>
References: <1104432914.15601.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        snort2004@mail.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
Content-Disposition: inline
In-Reply-To: <1104432914.15601.19.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Dec 30, 2004 at 07:55:14PM +0100, Bart De Schuymer wrote:

> ip_sabotage_out() needs to distinguish IPv4 and IPv6 traffic. It
> currently does that by looking at skb->protocol. However, for locally
> originated packets, skb->protocol is not initialized.
> The patch below instead looks at the version number of the packet's
> data, which should be 4 or 6.

A while ago there were a number of problems with bridging CIPE ethernet
devices, which turned out to be the bridge code not initialising
skb->protocol for locally originated STP frames.

At the time I was told that initialising skb->protocol for locally
originated packets is required, so that is how I fixed it then.


cheers,
Lennert
