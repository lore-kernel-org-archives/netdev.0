From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Thu, 27 May 2004 09:47:33 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526234732.GA5958@sgi.com>
References: <B1508D50A0692F42B217C22C02D849727FEDB8@NT-IRVA-0741.brcm.ad.broadcom.com> <20040526160443.GD4557@sgi.com> <20040526110121.657f2d42.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040526110121.657f2d42.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 26, 2004 at 11:01:21AM -0700, David S. Miller wrote:
> On Thu, 27 May 2004 02:04:43 +1000
> Greg Banks <gnb@sgi.com> wrote:
> 
> > [...] is there a good reason why the tg3 driver uses
> > the on-chip SRAM send ring by default instead of the host send
> > ring?[...]
> 
> It actually results in better performance to use PIOs to the
> chip to write the TXD descriptors.  You may be skeptical about
> this but it cannot be denied that it does result in lower
> latency as we don't have to wait for the chip to do it's next
> prefetch and _furthermore_ this means that no CPU cache lines
> will bounce from cpu-->device in order to get the descriptors
> to the chip.

Actually I am skeptical.  I suspect the performance difference
is dependent on chipset and load.

In the case I'm looking at (multiple NIC NFS read loads) there would be
7 to 10 32-bit PIOs emitted per call to tg3_start_xmit.  With 3 NICs'
worth of near line-rate traffic going through one chipset, that's a
lot of PIOs.  The scaling work we're doing will require 2 to 3 times
more traffic than this.  For this kind of load the latency cost may
be worth the efficiency gain for the chipset.

If we can show a performance improvement on our hardware, would you
accept a patch to enable host send rings on our hardware only?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
