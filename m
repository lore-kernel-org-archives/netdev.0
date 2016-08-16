From: John Fleming <john@spikefishsolutions.com>
Subject: DSA + Marvell embedded switch question
Date: Mon, 15 Aug 2016 20:17:24 -0400
Message-ID: <CABy3cGyiS7ZqcuKiYkPKWFM3kOph_Yw1bpR+x1cO-5W+Zh4+Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36536 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576AbcHPAR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 20:17:26 -0400
Received: by mail-wm0-f52.google.com with SMTP id q128so115116038wma.1
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 17:17:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all, I have a embedded appliance I bought from a vendor and i'm
being told to file a RFE for this.

The issue i have is the device has a embedded Marvell switch (88E1514
?). LAN1 through LAN6 are part of a single bridge group by default.
Not sure if that is the correct term because i don't think it was
created via brctl and doesn't show up in there.

This is what ethtool shows as the driver. Looks like the driver name
is marvellmod based on lsmod output.

ethtool -i LAN1
driver: marvell switch port
version: 1.0
firmware-version:
bus-info: switch SMI bus
supports-statistics: no
supports-test: no
supports-eeprom-access: no
supports-register-dump: no
supports-priv-flags: no

Also found this
crw-r--r--    1 root     root      10,   3 Aug 15 17:49 /dev/marvell

Not sure if there is a way to probe this device for info.

kernel is

3.10.20-al-5.0-pr2 #1 SMP Thu Jun 16 14:48:21 IDT 2016 armv7l arm

I've also noticed this internal interface called al_eth. Not sure if
this is some kind of device that hooks everything together. It doesn't
seem to be attached to a physical port.

[Expert@FWCKP750]# ethtool -i eth1
driver: al_eth
version: 0.2
firmware-version:
bus-info: 0000:00:01.0
supports-statistics: no
supports-test: no
supports-eeprom-access: no
supports-register-dump: no
supports-priv-flags: no

>From what i've read i think the bridge command should be able to read
this information, however doing for example bridge show fdb will show
all hosts being behind LAN1 even if its really plugged into LAN2 or
LAN3.

Just wondering if anyone can point me to something that could pull
this information. I don't have any C know how, but if nudged in the
right direction i think i could figure it out.

Thanks!
