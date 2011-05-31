From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_options_compile: properly handle unaligned pointer
Date: Tue, 31 May 2011 15:13:21 -0700 (PDT)
Message-ID: <20110531.151321.494228226.davem@davemloft.net>
References: <201105292112.p4TLC6cN017178@farm-0002.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201105292112.p4TLC6cN017178@farm-0002.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Sun, 29 May 2011 16:55:44 -0400

> The current code takes an unaligned pointer and does htonl() on it to
> make it big-endian, then does a memcpy().  The problem is that the
> compiler decides that since the pointer is to a __be32, it is legal
> to optimize the copy into a processor word store.  However, on an
> architecture that does not handled unaligned writes in kernel space,
> this produces an unaligned exception fault.
> 
> The solution is to track the pointer as a "char *" (which removes a bunch
> of unpleasant casts in any case), and then just use put_unaligned_be32()
> to write the value to memory.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

Applied, thanks Chris.
