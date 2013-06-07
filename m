From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Scaling problem with a lot of AF_PACKET sockets on different
 interfaces
Date: Fri, 07 Jun 2013 06:54:49 -0700
Message-ID: <1370613289.24311.419.camel@edumazet-glaptop>
References: <51B1CA50.30702@telenet.dn.ua>
	 <1370608871.5854.64.camel@marge.simpson.net>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B727B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <bitbucket@online.de>,
	"Vitaly V. Bursov" <vitalyb@telenet.dn.ua>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B727B@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-07 at 14:30 +0100, David Laight wrote:

> Looks like the ptype_base[] should be per 'dev'?
> Or just put entries where ptype->dev != null_or_dev on a per-interface
> list and do two searches?

Yes, but then we would have two searches instead of one in fast path.

ptype_base[] is currently 16 slots, 256 bytes on x86_64.
Presumably the per device list could be a single list, instead of a hash
table, but still...

If the application creating hundred or thousand of AF_PACKET sockets is
a single process, I really question why using a single AF_PACKET was not
chosen.

We now have a FANOUT capability on AF_PACKET, so that its scalable to
million of packets per second.

I would rather try this way before adding yet another section in
__netif_receive_skb()
