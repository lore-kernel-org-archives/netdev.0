From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Thu, 27 May 2004 09:50:08 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526235008.GB5958@sgi.com>
References: <B1508D50A0692F42B217C22C02D849727FEDBE@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <B1508D50A0692F42B217C22C02D849727FEDBE@NT-IRVA-0741.brcm.ad.broadcom.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 26, 2004 at 10:43:10AM -0700, Michael Chan wrote:
> 
> > [...] is there a good reason why the tg3 driver 
> > uses the on-chip SRAM send ring by default instead of the 
> > host send ring?[...]
> 
> I can only speak for the Broadcom bcm5700 driver. We used to use NIC
> send BDs by default before zero copy transmit and TSO were implemented
> in the kernel. Using only one BD per packet at that time, we found that
> performance on some machines were sometimes slightly better. Especially
> with logic to save some PIO when some of the fields in the BD have not
> changed. The driver has now been changed to use host send BDs to perform
> better with zero copy and especially TSO where you may need many BDs per
> packet. I would recommend tg3 to make the switch also.

Ah, it's precisely the zero copy case I'm interested in.  I've measured
2 to 3 BDs per packet under my load.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
