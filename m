From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: 2.6.7 kernel boot-time configuration of a non-modular tulip
 driver
Date: Mon, 2 Aug 2004 08:38:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040802083837.131a17e3.rddunlap@osdl.org>
References: <200408021341.i72Df9TP021569@nlp0.cs.usyd.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bruce@it.usyd.edu.au
Return-path: <netdev-bounce@oss.sgi.com>
To: bruce@it.usyd.edu.au (Bruce Janson)
In-Reply-To: <200408021341.i72Df9TP021569@nlp0.cs.usyd.edu.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 02 Aug 2004 23:29:20 +1000 Bruce Janson wrote:

| Hi Randy,
|     Thanks for your reply.
| 
|     (moving this to netdev mailing list)
|     ...
| 
| [OK, but please Cc me explicitly as I don't subscribe to netdev.]
| 
|     On Sun, 01 Aug 2004 00:48:22 +1000 Bruce Janson wrote:
|     
|     | I have a linux 2.6.7 kernel which contains a compiled-in tulip driver.
|     | I would like to be able to boot the kernel with parameters that
|     | will allow control of the tulip device.  On some ethernet devices
|     | this used to be possible via (something like):
|     | 
|     |   ether=0,0,1,0,eth0
|     | 
|     | which would pass the four numeric parameters (as, I think, dev->irq,
|     | dev->ioaddr, dev->mem_start and dev->mem_end) to the net driver that
|     | controlled eth0.  A convention adopted by some net drivers then allowed
|     | dev->mem_start to be interpretted as a set of flags that would control
|     | device characteristics (e.g. full-duplex vs half-duplex mode).
|     | In .../linux-2.6.7/drivers/net/tulip/tulip_core.c:1587:
|     | 
|     |   if (dev->mem_start & MEDIA_MASK)
|     |     tp->default_port = dev->mem_start & MEDIA_MASK;
|     | 
|     | suggests that this might still work.  However, I have been unable
|     | to force dev->mem_start in that driver to become non-zero via any
|     | kernel boot-time parameters.  My limited understanding of the code
|     | that precedes the above lines in that file suggests that the "dev"
|     | structure is not what it used to be...
|     
|     The driver never calls netdev_boot_setup_check(), which is
|     what would give the driver its command line parameters.
|     
|     Did this work in early 2.6.x?  There have been several changes
|     in this area.
|     ...
| 
| No idea.  This is the first in the 2.6 kernel series that I have
| tried.
| 
|     The driver can't do a simple call to netdev_boot_setup_check()
|     because that will overwrite dev-> {irq, base_addr, mem_start, mem_end},
|     and those values come from PCI config space for PCI drivers.
|     The driver could create a fake <dev> for that purpose, but it's
|     more likely that ethtool or mii-tool should be used to change
|     media/speed etc...  Although now that I look at the driver source
|     code, I don't see ethtool or mii-tool support for those options.
|     ...
| 
| Yes (tried that too :-().

Which/what have you tried?

Is it possible for you to use the tulip driver as modular instead
of builtin?  With modular, you can set the parameters...
but your environment may not allow modular?

|     | ../linux-2.6.7/Documentation/kernel-parameters.txt:402 still
|     | mentions "ether=..." but marks it as obsolete, replaced by
|     | the equivalent "netdev=...".  Elsewhere in that file, the entry
|     | for "netdev=..." describes what appears to be the functionality
|     | that I seek.
|     | 
|     | So, is it still possible to perform the same sort of control
|     | operations on a tulip driver via kernel boot-time parameters
|     | as one can do via module load-time parameters?  If so, how?
|     
|     The current tulip-core driver supports setting only the default transceiver
|     (media type) on the kernel boot/command line when the driver is built into
|     the kernel image (using mem_start, as you noted above).
|     ...
| 
| Sorry, I don't follow the above.  Would you mind giving me an example,
| please, of how for the tulip driver I might set the default transceiver
| (media type) on the kernel boot/command line when the driver is built
| into the kernel image?

No, I can't.  tulip-core uses <mem_start> to mean transceiver, but
like I said above, it never calls netdev_boot_setup_check() to get that
data, so it's useless currently.  Sorry.

I'm hoping that someone else will chime in with suggestions for
the right thing to do here.

--
~Randy
