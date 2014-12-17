From: Joshua Watt <jpewdev@gmail.com>
Subject: Question about phys_port_id
Date: Wed, 17 Dec 2014 10:09:31 -0600
Message-ID: <CAEPrYjTZ8SU1y4TwKHYtZju+4_-O5mazAjaFKaKmR2cYuAKHnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:65505 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbaLQQJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 11:09:32 -0500
Received: by mail-qa0-f46.google.com with SMTP id n8so11285203qaq.33
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 08:09:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I had a question regarding the phys_port_id attribute of net_device.
Is that identifier supposed to be globally unique or just unique among
devices that share a common device? For example, we have a single
device that create two net_device s (one for each of it's macs). Would
it be sufficient for this device to return a phys_port_id of 0 for the
first net_device and 1 for the second? I noticed that the other
implementations that use phys_port_id copy their mac address into the
phys_port_id, but I'm not sure if that is just because that is an easy
way to get a unique number or if it is because the ID needs to be
globally unique.

If you're wondering the driver in question is the TI cpsw driver
(drivers/net/ethernet/ti/cpsw.c). We are running the device in
dual-emac mode and need to uniquely identify which emac is which in
userspace (specifically, udev rules). The physical port identifier
seems to be the logical choice to me, but I'm not sure if I'm missing
something.

Thanks,
Joshua Watt
