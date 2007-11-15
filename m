From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3: strange errors and non-working-ness
Date: Thu, 15 Nov 2007 11:23:23 -0800
Message-ID: <1195154603.6360.9.camel@dell>
References: <20071115094728.GB2366@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Jon Nelson" <jnelson@jamponi.net>,
	"netdev" <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: "Jarek Poplawski" <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3723 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755171AbXKOSdh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 13:33:37 -0500
In-Reply-To: <20071115094728.GB2366@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-11-15 at 10:47 +0100, Jarek Poplawski wrote:
> On 13-11-2007 19:57, Jon Nelson wrote:
> > The best info I've got is this:

It looks like the card is being reset periodically.  Every time the card
gets reset, you'll see those PM messages in the version of the driver
you're using.  Do you see NETDEV WATCHDOG message as well in the dmesg
log?

> > 
> > Nov 10 22:21:19 frank kernel: tg3.c:v3.65 (August 07, 2006)
> > Nov 10 22:21:19 frank kernel: ACPI: PCI Interrupt 0000:00:0b.0[A] ->
> > Link [LNKB] -> GSI 3 (level, low) -> IRQ 3
> > Nov 10 22:21:19 frank kernel: eth0: Tigon3 [partno(AC91002A1) rev 0105
> > PHY(5701)] (PCI:33MHz:32-bit) 10/100/1000BaseT Ethernet
> > 00:09:5b:09:b1:69
> > Nov 10 22:21:19 frank kernel: eth0: RXcsums[1] LinkChgREG[0] MIirq[0]
> > ASF[0] Split[0] WireSpeed[1] TSOcap[0]
> > Nov 10 22:21:19 frank kernel: eth0: dma_rwctrl[76ff000f] dma_mask[64-bit]
> > Nov 10 22:21:19 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> > Nov 10 22:21:19 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> > Nov 10 22:21:19 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> > Nov 10 22:21:19 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> > Nov 10 22:21:20 frank kernel: tg3: eth0: Link is up at 1000 Mbps, full duplex.
> > Nov 10 22:21:20 frank kernel: tg3: eth0: Flow control is on for TX and
> > on for RX.
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> > Nov 10 22:21:20 frank kernel: ACPI: PCI interrupt for device
> > 0000:00:0b.0 disabled
> > Nov 10 22:21:20 frank kernel: PCI: Enabling device 0000:00:0b.0 (0100 -> 0102)
> > Nov 10 22:21:20 frank kernel: ACPI: PCI Interrupt 0000:00:0b.0[A] ->
> > Link [LNKB] -> GSI 3 (level, low) -> IRQ 3
> > Nov 10 22:21:20 frank kernel: eth0: Tigon3 [partno(AC91002A1) rev 0105
> > PHY(5701)] (PCI:33MHz:32-bit) 10/100/1000BaseT Ethernet
> > 00:09:5b:09:b1:69
> > Nov 10 22:21:20 frank kernel: eth0: RXcsums[1] LinkChgREG[0] MIirq[0]
> > ASF[0] Split[0] WireSpeed[1] TSOcap[0]
> > Nov 10 22:21:20 frank kernel: eth0: dma_rwctrl[76ff000f] dma_mask[64-bit]
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> > Nov 10 22:21:20 frank kernel: tg3: eth0: Link is up at 1000 Mbps, full duplex.
> > Nov 10 22:21:20 frank kernel: tg3: eth0: Flow control is on for TX and
> > on for RX.
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> > Nov 10 22:21:20 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> > Nov 10 22:21:20 frank kernel: tg3: eth0: Link is up at 1000 Mbps, full duplex.
> > Nov 10 22:21:20 frank kernel: tg3: eth0: Flow control is on for TX and
> > on for RX.
> > Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> > Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> > Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> > Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> > Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> > Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> > Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> > Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> > Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> > Nov 10 22:24:40 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> > Nov 10 22:41:48 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> > Nov 10 22:41:48 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> > Nov 10 22:41:48 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> > Nov 10 22:41:48 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> > Nov 10 22:41:48 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> > Nov 10 22:41:49 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> > Nov 10 22:41:49 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> > Nov 10 22:41:49 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> > Nov 10 22:41:49 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> > Nov 10 22:43:02 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> > Nov 10 22:45:52 frank kernel: NETDEV WATCHDOG: eth0: transmit timed out
> > Nov 10 22:45:52 frank kernel: tg3: eth0: transmit timed out, resetting
> > Nov 10 22:45:52 frank kernel: tg3: tg3_stop_block timed out, ofs=1400
> > enable_bit=2
> > Nov 10 22:45:52 frank kernel: tg3: tg3_stop_block timed out, ofs=c00
> > enable_bit=2
> > Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> > Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> > Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> > Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> > Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> > Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset b (was 164514e4, writing 302a1385)
> > Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 3 (was 0, writing 4008)
> > Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 2 (was 2000000, writing 2000015)
> > Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 1 (was 2b00000, writing 2b00106)
> > Nov 10 22:45:52 frank kernel: PM: Writing back config space on device
> > 0000:00:0b.0 at offset 0 (was 164514e4, writing 3ea173b)
> > Nov 10 22:45:52 frank kernel: tg3: eth0: Link is down.
> > Nov 10 22:45:56 frank kernel: tg3: eth0: Link is up at 1000 Mbps, full duplex.
> > Nov 10 22:45:56 frank kernel: tg3: eth0: Flow control is on for TX and
> > on for RX.
> > Nov 10 22:47:49 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> > Nov 10 22:47:49 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> > Nov 10 22:47:49 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> > Nov 10 22:49:02 frank kernel: nfs: server 192.168.2.1 not responding, timed out
> > 
> > Other gig-e cards work OK in this box.
> > I have a *pair* of the TG3 boards and they both do the same thing.
> > 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

