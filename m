From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Bug#396185: sky2 freezes in 2.6.17-2-686. Maintainer confirms
 that it should be fixed in 2.6.19-git tree.
Date: Thu, 16 Nov 2006 09:38:21 -0800
Message-ID: <20061116093821.318efbe6@freekitty>
References: <20061031073030.6658.11274.reportbug@kano.factory.vocord.ru>
	<20061031085716.GW13178@baikonur.stro.at>
	<20061031093051.GA3323@2ka.mipt.ru>
	<20061031093455.GX13178@baikonur.stro.at>
	<20061031094424.GA19052@2ka.mipt.ru>
	<20061116173532.GA10653@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: maximilian attems <maks@sternwelten.at>, 396185@bugs.debian.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50394 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161829AbWKPRij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 12:38:39 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061116173532.GA10653@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Nov 2006 20:35:32 +0300
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> On Tue, Oct 31, 2006 at 12:44:25PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > > > > Bug was filled against 2.6.17-9, but was fixed in recent git (2.6.19-rc3), probably also
> > > > > > fixed in 2.6.18.1
> > > > > > 
> > > > > > Here is link to discussion:
> > > > > > http://marc.theaimsgroup.com/?l=linux-netdev&m=116227512815783&w=2
> > > > > > 
> > > > > 
> > > > > can you try the linux-image 2.6.18, they are in unstable
> > > > > and the etch release images.
> 
> 2.6.18-1-686 kernel still allows to freeze sky2.

Fix didn't go in until 2.6.18.2

> There is nothing in dmesg and card just stops transmitting and
> receiving.
> rmmod/modproble helps in this situation though, so it is probably 
> not 100% the same bug as described in above link.
> 
> It looks like it happens when device is in promiscuous mode some traffic
> is started, at least I did not see such freezes when device operates in 
> usual mode, but it can be unrelated though.
> 
> I would say it is 100% reproducible, but only in current state - I do
> not know what will happen when I reboot. With tcpdump -n host 224.0.0.123
> and scp of the big file from sky2 to via_rhine 100mbit I'm able to
> reproduce that bug 100%, without tcpdump it seems to work correct.
> 
> Here is rmmod/modprobe dmesg:
> 
> ACPI: PCI interrupt for device 0000:05:00.0 disabled
> PCI: Enabling device 0000:05:00.0 (0000 -> 0003)
> ACPI: PCI Interrupt 0000:05:00.0[A] -> Link [LNKD] -> GSI 17 (level,low) -> IRQ 106
> PCI: Setting latency timer of device 0000:05:00.0 to 64
> sky2 v1.5 addr 0xfbefc000 irq 106 Yukon-EC (0xb6) rev 2
> sky2 eth0: addr 00:17:31:9a:e5:be
> sky2 eth0: enabling interface
> ADDRCONF(NETDEV_UP): eth0: link is not ready
> sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control both
> ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> eth0: no IPv6 routers present
> 
> Here is line from /proc/interrupts when device was frozen again:
> 114:    3257078          0         PCI-MSI  sky2
> 
> Above number does not change when card is frozen and starts increasing
> after rmmod/modprobe.
> 
> Attached statistic and register dumps for working and frozen states.
> 

Please retest with 2.76.18.2 or 2.6.19-rc6, there were some fixes
already there.

-- 
Stephen Hemminger <shemminger@osdl.org>
