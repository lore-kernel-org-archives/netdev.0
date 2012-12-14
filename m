From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: netconsole fun
Date: Fri, 14 Dec 2012 09:20:18 -0500
Message-ID: <20121214142018.GA24846@shamino.rdu.redhat.com>
References: <20121211143004.GA7481@neilslaptop.think-freely.org>
 <1355239011.2694.24.camel@thor>
 <20121211164526.GB7481@neilslaptop.think-freely.org>
 <1355345957.2687.18.camel@thor>
 <20121213123611.GA12269@hmsreliant.think-freely.org>
 <1355410171.2605.17.camel@thor>
 <20121213180815.GA14796@hmsreliant.think-freely.org>
 <1355426821.2612.16.camel@thor>
 <20121213211754.GC14796@hmsreliant.think-freely.org>
 <1355437480.2612.33.camel@thor>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37531 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755766Ab2LNOUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 09:20:35 -0500
Content-Disposition: inline
In-Reply-To: <1355437480.2612.33.camel@thor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2012 at 05:24:40PM -0500, Peter Hurley wrote:
> On Thu, 2012-12-13 at 16:17 -0500, Neil Horman wrote:
> > On Thu, Dec 13, 2012 at 02:27:01PM -0500, Peter Hurley wrote:
> > > On Thu, 2012-12-13 at 13:08 -0500, Neil Horman wrote:
> > > > On Thu, Dec 13, 2012 at 09:49:31AM -0500, Peter Hurley wrote:
> > > > > On Thu, 2012-12-13 at 07:36 -0500, Neil Horman wrote:
> > > > > > On Wed, Dec 12, 2012 at 03:59:17PM -0500, Peter Hurley wrote:
> > > > > > > On Tue, 2012-12-11 at 11:45 -0500, Neil Horman wrote:
> > > > > > > > On Tue, Dec 11, 2012 at 10:16:51AM -0500, Peter Hurley wrote:
> > > > > > > > > On Tue, 2012-12-11 at 09:30 -0500, Neil Horman wrote:
> > > > > > > > > > On Tue, Dec 11, 2012 at 09:19:52AM -0500, Peter Hurley wrote:
> > > > > > > > > > > On Tue, 2012-12-11 at 04:51 +0000, Cong Wang wrote:
> > > > > > > > > > > > On Mon, 10 Dec 2012 at 14:17 GMT, Peter Hurley <peter@hurleysoftware.com> wrote:
> > > > > > > > > > > > > Now that netpoll has been disabled for slaved devices, is there a
> > > > > > > > > > > > > recommended method of running netconsole on a machine that has a slaved
> > > > > > > > > > > > > device?
> > > > > > > > > > > > >
> > > > > > > > > > > > 
> > > > > > > > > > > > Yes, running it on the master device instead.
> > > > > > > > > > > 
> > > > > > > > > > > Thanks for the suggestion, but:
> > > > > > > > > > > 
> > > > > > > > > > > [ 0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-3.7.0-rc8-xeon ...... netconsole=@192.168.10.99/br0,30000@192.168.10.100/xx:xx:xx:xx:xx:xx
> > > > > > > > > > > ...
> > > > > > > > > > > [ 5.289869] netpoll: netconsole: local port 6665
> > > > > > > > > > > [ 5.289885] netpoll: netconsole: local IP 192.168.10.99
> > > > > > > > > > > [ 5.289892] netpoll: netconsole: interface 'br0'
> > > > > > > > > > > [ 5.289898] netpoll: netconsole: remote port 30000
> > > > > > > > > > > [ 5.289907] netpoll: netconsole: remote IP 192.168.10.100
> > > > > > > > > > > [ 5.289914] netpoll: netconsole: remote ethernet address xx:xx:xx:xx:xx:xx
> > > > > > > > > > > [ 5.289922] netpoll: netconsole: br0 doesn't exist, aborting
> > > > > > > > > > > [ 5.289929] netconsole: cleaning up
> > > > > > > > > > > ...
> > > > > > > > > > > [ 9.392291] Bridge firewalling registered
> > > > > > > > > > > [ 9.396805] device eth1 entered promiscuous mode
> > > > > > > > > > > [ 9.418350] eth1:  setting full-duplex.
> > > > > > > > > > > [ 9.421268] br0: port 1(eth1) entered forwarding state
> > > > > > > > > > > [ 9.423354] br0: port 1(eth1) entered forwarding state
> > > > > > > > > > > 
> > > > > > > > > > > 
> > > > > > > > > > > Is there a way to control or associate network device names prior to
> > > > > > > > > > > udev renaming?
> > > > > > > > > > > 
> > > > > > > > > > That looks like a systemd problem (or more specifically a boot dependency
> > > > > > > > > > problem).  You need to modify your netconsole unit/service file to start after
> > > > > > > > > > all your networking is up.  NetworkManager provides a dummy service file for
> > > > > > > > > > this purpose, called networkmanager-wait-online.service
> > > > > > > > > 
> > > > > > > > > Ok. So with a single physical network interface that will be bridged,
> > > > > > > > > netconsole cannot used for kernel boot messages.
> > > > > > > > > 
> > > > > > > > > With a machine with multiple nics, is there a way to control device
> > > > > > > > > naming so that the interface name to be used by netconsole specified on
> > > > > > > > > the boot command line will actually corresponding to the intended
> > > > > > > > > device. For example,
> > > > > > > > > 
> > > > > > > > > [ 0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-3.7.0-rc8-xeon ...... netconsole=@192.168.1.123/eth0,30000@192.168.1.139/xx:xx:xx:xx:xx:xx
> > > > > > > > > ....
> > > > > > > > > [ 4.092184] 3c59x: Donald Becker and others.
> > > > > > > > > [ 4.092204] 0000:07:05.0: 3Com PCI 3c905C Tornado at ffffc9000186cf80.
> > > > > > > > > [ 4.094035] tg3.c:v3.125 (September 26, 2012)
> > > > > > > > > ....
> > > > > > > > > [ 4.125038] tg3 0000:08:00.0 eth1: Tigon3 [partno(BCM95754) rev b002] (PCI Express) MAC address xx:xx:xx:xx:xx:xx
> > > > > > > > > [ 4.125055] tg3 0000:08:00.0 eth1: attached PHY is 5787 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
> > > > > > > > > [ 4.125062] tg3 0000:08:00.0 eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
> > > > > > > > > [ 4.125068] tg3 0000:08:00.0 eth1: dma_rwctrl[76180000] dma_mask[64-bit]
> > > > > > > > > 
> > > > > > > > > This is attaching netconsole to the wrong device because bus
> > > > > > > > > enumeration, and therefore load order, is not consistent from boot to
> > > > > > > > > boot.
> > > > > > > > > 
> > > > > > > > No, theres no way to do that.  As you note device ennumeration isn't consistent
> > > > > > > > accross boots, thats why udev creates rules to rename devices based on immutable
> > > > > > > > (or semi-immutable) data, like mac addresses, or pci bus locations).  Once that
> > > > > > > > happens, you'll have consistent names for your interfaces, and that work will be
> > > > > > > > guaranteed to be done after networkmanager has finished opening all the
> > > > > > > > interfaces that it needs (hence my suggestion to make netconsole service
> > > > > > > > dependent on networkmanager service startup completing).
> > > > > > > 
> > > > > > > Just wondering if you think something like the patch below is
> > > > > > > suitable/acceptable for insulating netconsole from inconsistent device
> > > > > > > name scenarios without changing the existing semantics. The basic idea
> > > > > > > is to allow an ethernet MAC address in the <dev> field of the
> > > > > > > netconsole= options, and if a MAC address was specified rather than a
> > > > > > > device name, to do the dev lookup from the MAC address instead.
> > > > > > > 
> > > > > > > This doesn't extend to, but also doesn't interfere with, the dynamic
> > > > > > > config of netconsole via configfs.
> > > > > > > 
> > > > > > > Would you mind reviewing it?
> > > > > > > 
> > > > > > > Regards,
> > > > > > > Peter
> > > > > > > 
> > > > > > This looks like a pretty good idea to me.  That said, something occured to me
> > > > > > when you wrote your summary above.  Have you looked at the netconsole service
> > > > > > scripts that most distros provide in their packaging?  I'm almost positive Red
> > > > > > Hat/Fedora (and also like Suse and Ubuntu), already implement this functionality
> > > > > > from user space.  Basically, instead of people just modprobing netconsole, they
> > > > > > create a service script that parses a config file that has contains all the
> > > > > > options needed to load the netconsole module, and it has the intellegence to see
> > > > > > if you specified a mac address rather than a device.  If you did that it finds
> > > > > > the corresponding device mac address and uses that as the device.  I'm sorry, I
> > > > > > don't know why I didn't think of that before.  Check that out though, that will
> > > > > > likey give you exactly what you need
> > > > > 
> > > > > Even with a udev rule to load netconsole that runs immediately after
> > > > > device renaming (so before scripting), most of the dynamic module
> > > > > loading has already happened so netconsole misses it. At least with the
> > > > > patch, netconsole will load and attach to the proper interface much
> > > > > earlier in the boot so that module-load-time messages will be caught.
> > > > > 
> > > > I'm not sure what you mean by this.
> > > 
> > > This is the beginning of my netconsole log if I use userspace scripts to
> > > start it.
> > > 
> > > [   19.125314] ip_tables: (C) 2000-2006 Netfilter Core Team
> > > [   20.060925] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
> > > [   21.829331] ip6_tables: (C) 2000-2006 Netfilter Core Team
> > > [   25.728370] at-spi-registry[1862]: segfault at 18 ip 00007f6dd1dd45f1 sp 00007fff49bcd760 error 4 in libgconf-2.so.4.1.5[7f6dd1dbd000+2d000]
> > > [   26.778848] EXT4-fs (dm-3): re-mounted. Opts: errors=remount-ro,commit=0
> > > [   30.643469] Bluetooth: RFCOMM TTY layer initialized
> > > [   30.643509] Bluetooth: RFCOMM socket layer initialized
> > > [   30.643512] Bluetooth: RFCOMM ver 1.11
> > > [   30.784550] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
> > > [   30.784567] Bluetooth: BNEP filters: protocol multicast
> > > [   30.784584] Bluetooth: BNEP socket layer initialized
> > > [   34.010813] init: plymouth-stop pre-start process (2205) terminated with status 1
> > > 
> > > This is the beginning of my netconsole log if I am able to specify
> > > netconsole= options on the boot command line. Netconsole starts logging
> > > much earlier because it is much loaded earlier.
> > > 
> > > [    8.764336] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
> > > [    9.409379] firewire_core 0000:07:06.0: created device fw1: GUID 0800460301c2d69e, S400
> > > [    9.567395] init: ureadahead main process (500) terminated with status 5
> > > [   10.400338] Adding 10996456k swap on /dev/mapper/isw_cbdbfhdjad_Raid0p5.  Priority:-1 extents:1 across:10996456k 
> > > [   10.496974] udevd[541]: starting version 173
> > > [   10.725906] EXT4-fs (dm-4): re-mounted. Opts: errors=remount-ro
> > > [   11.288352] lp: driver loaded but no devices found
> > > [   12.240058] parport_pc 00:05: reported by Plug and Play ACPI
> > > [   12.240145] parport0: PC-style at 0x378 (0x778), irq 7, using FIFO [PCSPP,TRISTATE,COMPAT,ECP]
> > > [   12.336161] lp0: using parport0 (interrupt-driven).
> > > [   12.342867] microcode: CPU0 sig=0x10676, pf=0x40, revision=0x60f
> > > [   12.436657] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
> > > [   12.442245] ppdev: user-space parallel port driver
> > > [   12.451592] net firewire0: IPv4 over IEEE 1394 on card 0000:07:06.0
> > > 
> > > Does that make more sense now?
> > > 
> > No, actually, what exactly are you trying to show me here?  I don't see any
> > indication of netconsole doing anything in either of these log snippets.
>                  ^^^^^^^^^^^^^^^^^^^^^^
>       except that it was netconsole that wrote these logs
> 
> Note the log times.
> 
> In the first log, which is from a netconsole loaded by userspace
> scripts, the first printk it logs isn't until 19.125314 secs into boot.
> Most kernel + module init has already happened by this time.
> 
> In the second log, which is from a netconsole (still built as a module)
> loaded as a result of using the boot command line. It starts logging at
> 8.764336 secs into boot -- almost 10 secs earlier than using userspace
> scripting to load netconsole.
> 
> > I'm
> > also not sure why you're specifying netconsole options on the kernel command
> > line at all.
> > Can you elaborate?
> 
> Specifying netconsole= on the boot command line loads the netconsole
> module at the earliest possible time (and much earlier than scripting
> will do). And also leaves it as an optional configuration (at least for
> me it does since I use grub2 and can edit the boot command line before
> booting).
> 
> AFAIK, there are 5 ways to load netconsole:
> 1. On the boot command line with netconsole=
>    If netconsole is built-in, this is the only way to initialize it.
>    If netconsole is a module, this forces netconsole to load at the
>    earliest possible time.
> 2. Via /etc/modules
>    This happens before network device renaming, so suffers from the
>    problems we've been discussing.
> 3. Via a custom udev rule in /etc/udev/rules.d/
>    Earliest userspace method to modprobe netconsole and can be used
>    after device renaming, but is still fairly late in the boot process.
> 4. Via init/service scripting
> 5. At the user shell
> 
> AFAIK, there are 4 ways to specify the necessary options to netconsole:
> a. On the boot command line with netconsole=
>    Also loads netconsole
> b. In a .conf file in /etc/modprobe.d
> c. On the modprobe command line
> d. Via configfs
> 
Ah!  I'm sorry, I didn't realize this was really about getting netconsole up
early in the boot, rather than just getting it up robustly using the startup
script.  If thats the case, then I would recommend that you modify the initramfs
to do something simmilar to the startup script (since thats where the netconsole
module will get loaded anyway).  You can write a script there that will let you
specify the destination ip address and figure out the output dev based on the
routing tables.  If you're using dracut to build your initramfs, then this
should be pretty straightforward.

Neil

> Regards,
> Peter
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
