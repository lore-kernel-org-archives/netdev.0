From: Feng Tang <feng.tang@intel.com>
Subject: Re: [PATCH v2] net: alx: use custom skb allocator
Date: Thu, 26 May 2016 16:41:55 +0800
Message-ID: <20160526084155.GB11823@shbuild888>
References: <1464158994-7725-1-git-send-email-feng.tang@intel.com>
 <20160525.195341.342679643310465817.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edumazet@google.com, johannes@sipsolutions.net, jarod@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160525.195341.342679643310465817.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 25, 2016 at 07:53:41PM -0400, David Miller wrote:
> From: Feng Tang <feng.tang@intel.com>
> Date: Wed, 25 May 2016 14:49:54 +0800
> 
> > This patch follows Eric Dumazet's commit 7b70176421 for Atheros
> > atl1c driver to fix one exactly same bug in alx driver, that the
> > network link will be lost in 1-5 minutes after the device is up.
> > 
> > My laptop Lenovo Y580 with Atheros AR8161 ethernet device hit the
> > same problem with kernel 4.4, and it will be cured by Jarod Wilson's
> > commit c406700c for alx driver which get merged in 4.5. But there
> > are still some alx devices can't function well even with Jarod's
> > patch, while this patch could make them work fine. More details on
> > 	https://bugzilla.kernel.org/show_bug.cgi?id=70761
> > 
> > The debug shows the issue is very likely to be related with the RX
> > DMA address, specifically 0x...f80, if RX buffer get 0x...f80 several
> > times, their will be RX overflow error and device will stop working.
> > 
> > For kernel 4.5.0 with Jarod's patch which works fine with my
> > AR8161/Lennov Y580, if I made some change to the
> > 	__netdev_alloc_skb
> > 		--> __alloc_page_frag()
> > to make the allocated buffer can get an address with 0x...f80,
> > then the same error happens. If I make it to 0x...f40 or 0x....fc0,
> > everything will be still fine. So I tend to believe that the
> > 0x..f80 address cause the silicon to behave abnormally.
> > 
> > Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=70761
> > Cc: Eric Dumazet <edumazet@google.com>
> > Cc: Johannes Berg <johannes@sipsolutions.net>
> > Cc: Jarod Wilson <jarod@redhat.com>
> > Signed-off-by: Feng Tang <feng.tang@intel.com>
> > Tested-by: Ole Lukoie <olelukoie@mail.ru>
> 
> Looks good, applied, thanks.

Thanks for reviewing and taking it.

> 
> But now that we have at least two instances of this code we really
> need to put a common version somewhere. :-/

I agree, and furthermore I noticed there are some similar routines
in the 4 individual Atheros drivers atlx/alx/atl1c/atl1e, which may
be unified by a simple framework for them all. Maybe the driver
maintainer from Atheros could take a look, as they can reach all
the real HWs :)

Thanks,
Feng
