From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
Date: Tue, 21 Apr 2009 00:09:43 -0600
Message-ID: <fa686aa40904202309m1ce37e9dse38725e49c395852@mail.gmail.com>
References: <20090224000002.GA578@ovro.caltech.edu> <200902261715.28440.arnd@arndb.de>
	<20090226200110.GA19523@ovro.caltech.edu> <200902262137.15169.arnd@arndb.de>
	<20090226214919.GA19959@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Ira Snyder <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:19508 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbZDUGKA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 02:10:00 -0400
In-Reply-To: <20090226214919.GA19959@ovro.caltech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 3:49 PM, Ira Snyder <iws@ovro.caltech.edu> wrot=
e:
> On Thu, Feb 26, 2009 at 09:37:14PM +0100, Arnd Bergmann wrote:
>> If the registers for setting up this window don't logically fit
>> into the same device as the one you already use, the cleanest
>> solution would be to have another device just for this and then
>> make a function call into that driver to set up the window.
>
> The registers are part of the board control registers. They don't fit=
 at
> all in the message unit. Doing this in the bootloader seems like a
> logical place, but that would require any testers to flash a new U-Bo=
ot
> image into their mpc8349emds boards.

Alternately, the board platform code (arch/powerpc/platforms/83xx) is
an ideal place for 'fixups'.  ie. to setup things that the firmware
really should be do, but doesn't.

>> > Now, I wouldn't need to access these registers at all if the bootl=
oader
>> > could handle it. I just don't know if it is possible to have Linux=
 not
>> > use some memory that the bootloader allocated, other than with the
>> > mem=3DXXX trick, which I'm sure wouldn't be acceptable. I've just =
used
>> > regular RAM so this is portable to my custom board (mpc8349emds ba=
sed)
>> > and a regular mpc8349emds. I didn't want to change anything board
>> > specific.
>> >
>> > I would love to have the bootloader allocate (or reserve somewhere=
 in
>> > the memory map) 16K of RAM, and not be required to allocate it wit=
h
>> > dma_alloc_coherent(). It would save me plenty of headaches.
>>
>> I believe you can do that through the "memory" devices in the
>> device tree, by leaving out a small part of the description of
>> main memory, at putting it into the "reg" property of your own
>> device.
>>
>
> I'll explore this option. I didn't even know you could do this. =A0Is=
 a
> driver that requires the trick acceptable for mainline inclusion? Jus=
t
> like setting up the 16K PCI window, this is very platform specific.

Yup.  You wouldn't even need to write any code to do this.  Just
reduce the memory node's RAM size listed in the .dts file by 16k and
add a 16K region to the reg property for the messaging region.

Speaking of which, the device tree changes should be adding 2 nodes; 1
node to describe the messaging unit, and 1 node to describe the virtio
instance.  The messaging unit is a general purpose piece of hardware,
so it is not appropriate to write a usage-specific device driver that
binds against it.  I'm kind of working on this right now, so I'll show
you what I mean in patch form when I actually get things running.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
