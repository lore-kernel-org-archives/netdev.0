From: Steve Sakoman <sakoman@gmail.com>
Subject: Re: [RFC PATCH] smsc911x: protect INT_EN read-modify-write with
	spinlock
Date: Sun, 25 Jan 2009 20:43:29 -0800
Message-ID: <5e088bd90901252043x4fd3b787n9cc72c9a48bce266@mail.gmail.com>
References: <1232460114-13469-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Ian Saturley <ian.saturley@smsc.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:31715 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbZAZEnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2009 23:43:31 -0500
Received: by fk-out-0910.google.com with SMTP id f33so2369049fkf.5
        for <netdev@vger.kernel.org>; Sun, 25 Jan 2009 20:43:29 -0800 (PST)
In-Reply-To: <1232460114-13469-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2009 at 6:01 AM, Steve Glendinning
<steve.glendinning@smsc.com> wrote:
> This patch adds a new spinlock to protect read-modify-writes to the
> INT_EN register when enabling and disabling interrupt sources.
>
> I haven't actually seen any devices lock up, but I think there's a
> possibility and I'd like to eliminate it.

I'm attempting to use this driver on a new Gumstix Overo daughtercard
that uses an SMCS9221 and have been having some interrupt issues that
may or may not be related.

I am using the version in linux-omap 2.6.29-rc2.  Here's what I see at boot:

smsc911x: Driver version 2008-10-21.
eth%d: smsc911x_init: Driver Parameters:
eth%d: smsc911x_init: LAN base: 0xD086E000
eth%d: smsc911x_init: IRQ: 336
eth%d: smsc911x_init: PHY will be autodetected.
eth%d: smsc911x_init: BYTE_TEST: 0x87654321
eth%d: smsc911x_init: LAN911x identified, idrev: 0x92210000, generation: 4
eth0: smsc911x_drv_probe: Network interface: "eth0"
eth0: smsc911x_mii_init: External PHY is not supported, using internal PHY
smsc911x-mdio: probed
eth0: smsc911x_mii_probe: PHY 1: addr 1, phy_id 0x0007C0C3
eth0: attached PHY driver [SMSC LAN8700] (mii_bus:phy_addr=ffffffff:01, irq=-1)
eth0: smsc911x_phy_check_loopbackpkt: Successfully verified loopback packet
eth0: smsc911x_mii_probe: Passed Loop Back Test
eth0: smsc911x_mii_probe: phy initialised succesfully
eth0: smsc911x_drv_probe: MAC Address is set to random_ether_addr
net eth0: MAC Address: ae:b1:a7:f7:89:c2
<snip>
Configuring network interfaces...
eth0: smsc911x_open: irq polarity: active low
eth0: smsc911x_open: irq type: open drain
eth0: smsc911x_open: Testing irq handler using IRQ 336
net eth0: ISR failed signaling test (IRQ 336)

I have a scope probe hanging on the IRQ signal.  I can see that IRQ is
high at power on, then I see a flurry of interrupts,  then at around
the time the "testing irq" message comes out I see IRQ go low and
remain low.  This behavior is 100% reproducible.

I tried with and without this patch, same behavior.

Any ideas what might be going wrong?

Steve
