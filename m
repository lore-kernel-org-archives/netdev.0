From: Jon Smirl <jonsmirl@gmail.com>
Subject: USB attached microcontroller with net interface
Date: Mon, 12 Jul 2010 09:55:20 -0400
Message-ID: <AANLkTilFk5FJENjQ-mafUeqvs9V4zcxhY-PEW3mcCcYK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:40819 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355Ab0GLNzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 09:55:21 -0400
Received: by qwh6 with SMTP id 6so1314721qwh.19
        for <netdev@vger.kernel.org>; Mon, 12 Jul 2010 06:55:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a USB stick with a microcontroller and a 802.15.4 radio on it.
The USB stick is fixed as a standard USB serial device by the hardware
but the device has a unique USB ID. What is the best strategy for
integrating this stick into Linux?

One option is the linux-zigbee model. The microcontroller runs a small
program which implements a private serial line protocol. On the Linux
side there is a device driver that understands this protocol and
implements a net device. The serial line protocol is implemented as a
line discipline - which requires a user space component to hold the
ttyUSBx device open. The protocol passes things like send packet,
receive packet, etc.. This implies that the 6lowpan/RPL support in
Linux gets finished.

Second option is to run TCP in the microcontroller. This model has
already been implemented in Contiki (a small OS for microcontrollers).
Contiki supports two network interfaces - SLIP and radio. It routes
everything between the interfaces. 6lowpan/RPL are running on the
microcontroller.  After you plug the device in you use ldattach on
ttyUSBx to get SLIP running over the USB serial port.

The 802.15.4 nets are running IPv6. A complicating factor is routing.
Say you have a building covered by a 802.15.4 RPL mesh. Now you plug
802.15.4 USB sticks into some PCs and create multiple gateways into
the RPL network. You want to use the closest gateway since mesh hops
are quite slow.

Is there another, better option? I'd like to get this working without
requiring a user space component.

-- 
Jon Smirl
jonsmirl@gmail.com
