From: Kushwaha Prabhakar-B32579 <B32579@freescale.com>
Subject: RE: [RFC v2] virtio: add virtio-over-PCI driver
Date: Sat, 7 May 2011 05:59:36 +0000
Message-ID: <071A08F2C6A57E4E94D980ECA553F8741A6056@039-SN1MPN1-004.039d.mgd.msft.net>
References: <071A08F2C6A57E4E94D980ECA553F8741A54D4@039-SN1MPN1-004.039d.mgd.msft.net>
 <20110506160627.GB14069@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Zang Roy-R61911 <R61911@freescale.com>,
	Gala Kumar-B11780 <B11780@freescale.com>,
	Gupta Maneesh-B18878 <B18878@freescale.com>,
	Aggrwal Poonam-B10812 <B10812@freescale.com>,
	Kalra Ashish-B00888 <B00888@freescale.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1outboundpool.messaging.microsoft.com ([216.32.181.182]:21894
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751908Ab1EGF7n convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 01:59:43 -0400
In-Reply-To: <20110506160627.GB14069@ovro.caltech.edu>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Ira for your kind reply.
I will look for the mentioned pointers :) 


Prabhakar 

> -----Original Message-----
> From: Ira W. Snyder [mailto:iws@ovro.caltech.edu]
> Sent: Friday, May 06, 2011 9:36 PM
> To: Kushwaha Prabhakar-B32579
> Cc: Zang Roy-R61911; Gala Kumar-B11780; Gupta Maneesh-B18878; Aggrwal
> Poonam-B10812; Kalra Ashish-B00888; linux-kernel@vger.kernel.org;
> linuxppc-dev@ozlabs.org; netdev@vger.kernel.org
> Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
> 
> On Fri, May 06, 2011 at 12:00:34PM +0000, Kushwaha Prabhakar-B32579
> wrote:
> > Hi,
> >
> > I want to use this patch as base patch for "FSL 85xx platform" to
> support PCIe Agent.
> > The work looks to be little old now. So wanted to understand if any
> development has happened further on it.
> >
> > In case no, I would take this work forward for PCIe Agent.
> >
> > Any help/suggestions are most appreciated in this regard.
> >
> 
> Hi Prabhakar,
> 
> I use PCI agent mode on an mpc8349emds board. All of the important setup
> is done very early in the boot process, by U-Boot. Search the U-Boot
> source for CONFIG_PCISLAVE. I hunch that the setup needed for 85xx boards
> are similar.
> 
> This virtio-over-PCI work is now very old. It was intended to provide a
> communication mechanism between a PCI Master and many PCI Agents
> (slaves).
> Dave Miller (networking maintainer) suggested to use virtio for this so
> that many different devices could be used. Such as:
> - network interface
> - serial port (for serial console)
> 
> I am aware of other ongoing work in this area. Specifically, some ARM
> developers are working on a virtio API using their message registers.
> This work is much newer, and will be a much better starting place for
> you.
> 
> Search the virtualization mailing list for:
> "[PATCH 00/02] virtio: Virtio platform driver"
> 
> Here is a link to some of their code:
> http://www.spinics.net/lists/linux-sh/msg07188.html
> 
> I am currently using a custom driver to provide a network device on my
> PCI agents. Searching the mailing list archives for "PCINet", you will
> find early versions of the driver. I am happy to provide you a current
> copy. It does not use virtio at all, and is unlikely to be accepted into
> mainline Linux.
> 
> I am happy to provide any of my code if you think it would help you get
> started. Specifically, the current version of "PCINet" show how to use
> the DMA controller in order to get good network performance. I am also
> happy to help port code to 83xx, as well as test on 83xx. Please ask any
> questions you may have.
> 
> I have people ask about this code about once every two months. There is
> plenty of interest in a mainline Linux solution to this problem. :) I
> will be moving to 85xx someday, and I hope there is an accepted mainline
> solution by then.
> 
> I hope it helps,
> Ira
> 
> > -----Original Message-----
> > From: linux-kernel-owner@vger.kernel.org
> > [mailto:linux-kernel-owner@vger.kernel.org] On Behalf Of Ira Snyder
> > Sent: Friday, 27 February, 2009 3:19 AM
> > To: Arnd Bergmann
> > Cc: linux-kernel@vger.kernel.org; Rusty Russell; Jan-Bernd Themann;
> > linuxppc-dev@ozlabs.org; netdev@vger.kernel.org
> > Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
> >
> > On Thu, Feb 26, 2009 at 09:37:14PM +0100, Arnd Bergmann wrote:
> > > On Thursday 26 February 2009, Ira Snyder wrote:
> > > > On Thu, Feb 26, 2009 at 05:15:27PM +0100, Arnd Bergmann wrote:
> > > >
> > > > I think so too. I was just getting something working, and thought
> > > > it would be better to have it "out there" rather than be working
> > > > on it forever. I'll try to break things up as I have time.
> > >
> > > Ok, perfect!
> > >
> > > > For the "libraries", would you suggest breaking things into
> > > > seperate code files, and using EXPORT_SYMBOL_GPL()? I'm not very
> > > > familiar with doing that, I've mostly been writing code within the
> > > > existing device driver frameworks. Or do I need export symbol at
> all? I'm not sure...
> > >
> > > You have both options. When you list each file as a separate module
> > > in the Makefile, you use EXPORT_SYMBOL_GPL to mark functions that
> > > get called by dependent modules, but this will work only in one way.
> > >
> > > You can also link multiple files together into one module, although
> > > it is less common to link a single source file into multiple modules.
> > >
> >
> > Ok. I'm more familiar with the EXPORT_SYMBOL_GPL interface, so I'll do
> that. If we decide it sucks later, we'll change it.
> >
> > > > I always thought you were supposed to use packed for data
> > > > structures that are external to the system. I purposely designed
> > > > the structures so they wouldn't need padding.
> > >
> > > That would only make sense for structures that are explicitly
> > > unaligned, like a register layout using
> > >
> > > struct my_registers {
> > > 	__le16 first;
> > > 	__le32 second __attribute__((packed));
> > > 	__le16 third;
> > > };
> > >
> > > Even here, I'd recommend listing the individual members as packed
> > > rather than the entire struct. Obviously if you layout the members
> > > in a sane way, you don't need either.
> > >
> >
> > Ok. I'll drop the __attribute__((packed)) and make sure there aren't
> problems. I don't suspect any, though.
> >
> > > > I mostly don't need it. In fact, the only place I'm using
> > > > registers not specific to the messaging unit is in the probe
> > > > routine, where I setup the 1GB window into host memory and setting
> > > > up access to the guest memory on the PCI bus.
> > >
> > > You could add the registers you need for this to the "reg" property
> > > of your device, to be mapped with of_iomap.
> > >
> > > If the registers for setting up this window don't logically fit into
> > > the same device as the one you already use, the cleanest solution
> > > would be to have another device just for this and then make a
> > > function call into that driver to set up the window.
> > >
> >
> > The registers are part of the board control registers. They don't fit
> at all in the message unit. Doing this in the bootloader seems like a
> logical place, but that would require any testers to flash a new U-Boot
> image into their mpc8349emds boards.
> >
> > The first set of access is used to set up a 1GB region in the memory
> map that accesses the host's memory. Any reads/writes to addresses
> 0x80000000-0xc0000000 actually hit the host's memory.
> >
> > The last access sets up PCI BAR1 to hit the memory from
> dma_alloc_coherent(). The bootloader already sets up the window as 16K,
> it just doesn't point it anywhere. Maybe this /should/ go into the
> bootloader. Like above, it would require testers to flash a new U-Boot
> image into their mpc8349emds boards.
> >
> > > > Now, I wouldn't need to access these registers at all if the
> > > > bootloader could handle it. I just don't know if it is possible to
> > > > have Linux not use some memory that the bootloader allocated,
> > > > other than with the mem=XXX trick, which I'm sure wouldn't be
> acceptable.
> > > > I've just used regular RAM so this is portable to my custom board
> > > > (mpc8349emds based) and a regular mpc8349emds. I didn't want to
> > > > change anything board specific.
> > > >
> > > > I would love to have the bootloader allocate (or reserve somewhere
> > > > in the memory map) 16K of RAM, and not be required to allocate it
> > > > with dma_alloc_coherent(). It would save me plenty of headaches.
> > >
> > > I believe you can do that through the "memory" devices in the device
> > > tree, by leaving out a small part of the description of main memory,
> > > at putting it into the "reg" property of your own device.
> > >
> >
> > I'll explore this option. I didn't even know you could do this.  Is a
> driver that requires the trick acceptable for mainline inclusion? Just
> like setting up the 16K PCI window, this is very platform specific.
> >
> > This limits the guest driver to systems which are able to change
> Linux's view of their memory somehow. Maybe this isn't a problem.
> >
> > > > Code complexity only. Also, it was easier to write 80-char lines
> > > > with something like:
> > > >
> > > > vop_get_desc(vq, idx, &desc);
> > > > if (desc.flags & VOP_DESC_F_NEXT) {
> > > > 	/* do something */
> > > > }
> > > >
> > > > Instead of:
> > > > if (le16_to_cpu(vq->desc[idx].flags) & VOP_DESC_F_NEXT) {
> > > > 	/* do something */
> > > > }
> > > >
> > > > Plus, I didn't have to remember how many bits were in each field.
> > > > I just thought it made everything simpler to understand.
> Suggestions?
> > >
> > > hmm, in this particular case, you could change the definition of
> > > VOP_DESC_F_NEXT to
> > >
> > > #define VOP_DESC_F_NEXT cpu_to_le16(1)
> > >
> > > and then do the code as the even simpler (source and object code
> > > wise)
> > >
> > > if (vq->desc[idx].flags) & VOP_DESC_F_NEXT)
> > >
> > > I'm not sure if you can do something along these lines for the other
> > > cases as well though.
> > >
> >
> > That's a good idea. It wouldn't fix the addresses, lengths, and next
> fields, though. I'll make the change and see how bad it is, then report
> back. It may not be so bad after all.
> >
> > > > I used 3 so they would would align to 1024 byte boundaries within
> > > > a 4K page. Then the layout was 16K on the bus, each 4K page is a
> > > > single virtio-device, and each 1K block is a single virtqueue. The
> > > > first 1K is for virtio-device status and feature bits, etc.
> > > >
> > > > Packing them differently isn't a problem. It was just easier to
> > > > code because setting up a window with the correct size is so
> > > > platform specific.
> > >
> > > Ok. I guess the important question is what part of the code makes
> > > this decision. Ideally, the virtio-net glue would instantiate the
> > > device with the right number of queues.
> > >
> >
> > Yeah, virtio doesn't work that way.
> >
> > The virtio drivers just call find_vq() with a different index for each
> queue they want to use. You have no way of knowing how many queues each
> virtio driver will want, unless you go read their source code.
> >
> > virtio-net currently uses 3 queues, but we only support the first two.
> > The third is optional (for now...), and non-symmetric.
> >
> > Thanks again,
> > Ira
> > --
> > To unsubscribe from this list: send the line "unsubscribe
> > linux-kernel" in the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> >
> >
> >
> >


