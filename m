From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: netconsole fun
Date: Thu, 13 Dec 2012 13:08:15 -0500
Message-ID: <20121213180815.GA14796@hmsreliant.think-freely.org>
References: <1355149033.3142.14.camel@thor>
 <ka6e4e$6k5$1@ger.gmane.org>
 <1355235592.2694.5.camel@thor>
 <20121211143004.GA7481@neilslaptop.think-freely.org>
 <1355239011.2694.24.camel@thor>
 <20121211164526.GB7481@neilslaptop.think-freely.org>
 <1355345957.2687.18.camel@thor>
 <20121213123611.GA12269@hmsreliant.think-freely.org>
 <1355410171.2605.17.camel@thor>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55404 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755308Ab2LMSIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 13:08:35 -0500
Content-Disposition: inline
In-Reply-To: <1355410171.2605.17.camel@thor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2012 at 09:49:31AM -0500, Peter Hurley wrote:
> On Thu, 2012-12-13 at 07:36 -0500, Neil Horman wrote:
> > On Wed, Dec 12, 2012 at 03:59:17PM -0500, Peter Hurley wrote:
> > > On Tue, 2012-12-11 at 11:45 -0500, Neil Horman wrote:
> > > > On Tue, Dec 11, 2012 at 10:16:51AM -0500, Peter Hurley wrote:
> > > > > On Tue, 2012-12-11 at 09:30 -0500, Neil Horman wrote:
> > > > > > On Tue, Dec 11, 2012 at 09:19:52AM -0500, Peter Hurley wrote:
> > > > > > > On Tue, 2012-12-11 at 04:51 +0000, Cong Wang wrote:
> > > > > > > > On Mon, 10 Dec 2012 at 14:17 GMT, Peter Hurley <peter@hurleysoftware.com> wrote:
> > > > > > > > > Now that netpoll has been disabled for slaved devices, is there a
> > > > > > > > > recommended method of running netconsole on a machine that has a slaved
> > > > > > > > > device?
> > > > > > > > >
> > > > > > > > 
> > > > > > > > Yes, running it on the master device instead.
> > > > > > > 
> > > > > > > Thanks for the suggestion, but:
> > > > > > > 
> > > > > > > [ 0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-3.7.0-rc8-xeon ...... netconsole=@192.168.10.99/br0,30000@192.168.10.100/xx:xx:xx:xx:xx:xx
> > > > > > > ...
> > > > > > > [ 5.289869] netpoll: netconsole: local port 6665
> > > > > > > [ 5.289885] netpoll: netconsole: local IP 192.168.10.99
> > > > > > > [ 5.289892] netpoll: netconsole: interface 'br0'
> > > > > > > [ 5.289898] netpoll: netconsole: remote port 30000
> > > > > > > [ 5.289907] netpoll: netconsole: remote IP 192.168.10.100
> > > > > > > [ 5.289914] netpoll: netconsole: remote ethernet address xx:xx:xx:xx:xx:xx
> > > > > > > [ 5.289922] netpoll: netconsole: br0 doesn't exist, aborting
> > > > > > > [ 5.289929] netconsole: cleaning up
> > > > > > > ...
> > > > > > > [ 9.392291] Bridge firewalling registered
> > > > > > > [ 9.396805] device eth1 entered promiscuous mode
> > > > > > > [ 9.418350] eth1:  setting full-duplex.
> > > > > > > [ 9.421268] br0: port 1(eth1) entered forwarding state
> > > > > > > [ 9.423354] br0: port 1(eth1) entered forwarding state
> > > > > > > 
> > > > > > > 
> > > > > > > Is there a way to control or associate network device names prior to
> > > > > > > udev renaming?
> > > > > > > 
> > > > > > That looks like a systemd problem (or more specifically a boot dependency
> > > > > > problem).  You need to modify your netconsole unit/service file to start after
> > > > > > all your networking is up.  NetworkManager provides a dummy service file for
> > > > > > this purpose, called networkmanager-wait-online.service
> > > > > 
> > > > > Ok. So with a single physical network interface that will be bridged,
> > > > > netconsole cannot used for kernel boot messages.
> > > > > 
> > > > > With a machine with multiple nics, is there a way to control device
> > > > > naming so that the interface name to be used by netconsole specified on
> > > > > the boot command line will actually corresponding to the intended
> > > > > device. For example,
> > > > > 
> > > > > [ 0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-3.7.0-rc8-xeon ...... netconsole=@192.168.1.123/eth0,30000@192.168.1.139/xx:xx:xx:xx:xx:xx
> > > > > ....
> > > > > [ 4.092184] 3c59x: Donald Becker and others.
> > > > > [ 4.092204] 0000:07:05.0: 3Com PCI 3c905C Tornado at ffffc9000186cf80.
> > > > > [ 4.094035] tg3.c:v3.125 (September 26, 2012)
> > > > > ....
> > > > > [ 4.125038] tg3 0000:08:00.0 eth1: Tigon3 [partno(BCM95754) rev b002] (PCI Express) MAC address xx:xx:xx:xx:xx:xx
> > > > > [ 4.125055] tg3 0000:08:00.0 eth1: attached PHY is 5787 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
> > > > > [ 4.125062] tg3 0000:08:00.0 eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
> > > > > [ 4.125068] tg3 0000:08:00.0 eth1: dma_rwctrl[76180000] dma_mask[64-bit]
> > > > > 
> > > > > This is attaching netconsole to the wrong device because bus
> > > > > enumeration, and therefore load order, is not consistent from boot to
> > > > > boot.
> > > > > 
> > > > No, theres no way to do that.  As you note device ennumeration isn't consistent
> > > > accross boots, thats why udev creates rules to rename devices based on immutable
> > > > (or semi-immutable) data, like mac addresses, or pci bus locations).  Once that
> > > > happens, you'll have consistent names for your interfaces, and that work will be
> > > > guaranteed to be done after networkmanager has finished opening all the
> > > > interfaces that it needs (hence my suggestion to make netconsole service
> > > > dependent on networkmanager service startup completing).
> > > 
> > > Just wondering if you think something like the patch below is
> > > suitable/acceptable for insulating netconsole from inconsistent device
> > > name scenarios without changing the existing semantics. The basic idea
> > > is to allow an ethernet MAC address in the <dev> field of the
> > > netconsole= options, and if a MAC address was specified rather than a
> > > device name, to do the dev lookup from the MAC address instead.
> > > 
> > > This doesn't extend to, but also doesn't interfere with, the dynamic
> > > config of netconsole via configfs.
> > > 
> > > Would you mind reviewing it?
> > > 
> > > Regards,
> > > Peter
> > > 
> > This looks like a pretty good idea to me.  That said, something occured to me
> > when you wrote your summary above.  Have you looked at the netconsole service
> > scripts that most distros provide in their packaging?  I'm almost positive Red
> > Hat/Fedora (and also like Suse and Ubuntu), already implement this functionality
> > from user space.  Basically, instead of people just modprobing netconsole, they
> > create a service script that parses a config file that has contains all the
> > options needed to load the netconsole module, and it has the intellegence to see
> > if you specified a mac address rather than a device.  If you did that it finds
> > the corresponding device mac address and uses that as the device.  I'm sorry, I
> > don't know why I didn't think of that before.  Check that out though, that will
> > likey give you exactly what you need
> 
> Even with a udev rule to load netconsole that runs immediately after
> device renaming (so before scripting), most of the dynamic module
> loading has already happened so netconsole misses it. At least with the
> patch, netconsole will load and attach to the proper interface much
> earlier in the boot so that module-load-time messages will be caught.
> 
I'm not sure what you mean by this.  I get that other drivers are loaded and
that if the netconsole service runs too soon, you might not have a network path
to the netconsole host you want, but as long as the network is up, the service
script (if properly written), shouldn't make you specify a network device.
Instead of having to specify the device to the netconsole module directly, the
config file for the service script lets you specify the destination ip address
of the netconsole server, and figures out the output device based on the routing
tables, whatever that device name happens to be on that boot.  So you don't
really need this patch, because user space can do this work (and more) for you.
You just have to wait for the network to come up, which you need to do anyway.

> There is an unforeseen consequence of the patch: it breaks device
> renaming because the device will already be in use by netconsole. Which
> is the whole problem with userspace device renaming to begin with...
> 
That is bad, but see above, the netconsole service can work around this for you,
allowing you to never have to specify a particular device at all.

> I guess that leaves only the option of building in netconsole and the
> driver that supplies the interface.
> 

> Oh well.
> 
> Regards,
> Peter
> 
> 
