From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] marvell sky2 driver: fix so it works without unaligned
 accesses
Date: Tue, 03 Apr 2012 17:46:10 -0400 (EDT)
Message-ID: <20120403.174610.2089715131687430500.davem@davemloft.net>
References: <201204031527.q33FR04i031747@farm-0027.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204031527.q33FR04i031747@farm-0027.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Tue, 3 Apr 2012 11:13:56 -0400

> The driver uses a receive_new() routine that ends up requiring unaligned
> accesses in IP header processing.  If the architecture doesn't support
> efficient unaligned accesses, just copy all ingress packets to the bounce
> buffers instead.
> 
> This allows the driver to be used on the Tilera TILEmpower-Gx, since
> the tile architecture doesn't currently handle kernel unaligned accesses,
> just userspace.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

As Stephen Hemminger alluded to, adjust the copybreak as needed.

If you look at how other device drivers use this CONFIG variable,
you'll get a better idea of what to do here if you want to adjust
the default copybreak.

Also keep in mind the issue brought up by Eric Dumazet in that
not all kinds of sky2 chips would need this copybreak adjustment,
only ones that have the SKY2_HW_RAM_BUFFER bit cleared.
