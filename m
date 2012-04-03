From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] marvell sky2 driver: fix so it works without unaligned
 accesses
Date: Tue, 3 Apr 2012 09:17:50 -0700
Message-ID: <20120403091750.11eff45b@s6510.linuxnetplumber.net>
References: <201204031527.q33FR04i031747@farm-0027.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204031527.q33FR04i031747@farm-0027.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Apr 2012 11:13:56 -0400
Chris Metcalf <cmetcalf@tilera.com> wrote:

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

There are many other encapsulation cases where IP header won't be
aligned. Why not just set copybreak module option to a very large value?
