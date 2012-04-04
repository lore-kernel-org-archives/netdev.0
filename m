From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] marvell sky2 driver: fix so it works without
 unaligned accesses
Date: Wed, 4 Apr 2012 09:04:52 -0700
Message-ID: <20120404090452.7f13a652@s6510.linuxnetplumber.net>
References: <20120403.174610.2089715131687430500.davem@davemloft.net>
	<1333469916.18626.284.camel@edumazet-glaptop>
	<201204031527.q33FR04i031747@farm-0027.internal.tilera.com>
	<201204041419.q34EJ49H025297@farm-0012.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204041419.q34EJ49H025297@farm-0012.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Apr 2012 10:13:32 -0400
Chris Metcalf <cmetcalf@tilera.com> wrote:

> The driver uses a receive_new() routine that ends up requiring unaligned
> accesses in IP header processing.  If the architecture doesn't support
> efficient unaligned accesses, and SKY2_HW_RAM_BUFFER is set,
> just copy all ingress packets to the bounce buffers instead.
> Thanks to Eric Dumazet for pointing out the SKY2_HW_RAM_BUFFER issue.
> 
> This allows the driver to be used on the Tilera TILEmpower-Gx, since
> the tile architecture doesn't currently handle kernel unaligned accesses,
> just userspace.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

Still kind of ugly, I will cleanup
