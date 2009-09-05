From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Staging: cpc-usb CAN driver TODO list
Date: Sat, 05 Sep 2009 15:08:27 +0200
Message-ID: <4AA262CB.7060607@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Felipe Balbi <me@felipebalbi.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Greg KH <greg@kroah.com>, Sebastian Haas <haas@ems-wuensche.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:61145 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbZIENIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2009 09:08:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Greg and Sebastian,

i just looked around in the linux-next tree for the cpc-usb driver.

http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=tree;f=drivers/staging/cpc-usb;hb=HEAD

IMHO the sja2m16c* files are completely obsolete as the setting of the CAN
bittimings needs to be done by separate functions (one for the SJA1000 and one
for the M16C). For both of them a separate can_bittiming_const is needed, like
it is defined in drivers/net/can/sja1000/sja1000.c:

static struct can_bittiming_const sja1000_bittiming_const = {
	.name = DRV_NAME,
	.tseg1_min = 1,
	.tseg1_max = 16,
	.tseg2_min = 1,
	.tseg2_max = 8,
	.sjw_max = 4,
	.brp_min = 1,
	.brp_max = 64,
	.brp_inc = 1,
};

Also a separate function to determine the register values from the calculated
bittiming values is needed for both hardware types (SJA1000(LPC2119)/M16C) of
the cpc-usb. How this is done can be checked in linux/drivers/net/can/* or in
the source code of upcoming drivers in

http://svn.berlios.de/svnroot/repos/socketcan/trunk/kernel/2.6/drivers/net/can/

I wondered about the following items in the TODO list:

	- tie into CAN socket interfaces if possible
	- figure out sane userspace api

This is definitely a no go! IMO there is no real alternative to make this
cpc-usb driver a real CAN network driver.

The CAN driver interface has a sane configuration API via netlink and brings
everything to configure CAN specific bitrates, error counters, recovery, etc.

The missing thing is to connect the usb-device to a netdevice (can%d), remove
all the chardev file-I/O stuff and adapt the cpc-usb to use the
bitrate-settings, error counters and whatever - which is already well-defined
and provided by the CAN driver interface library contributed by Wolfgang
Grandegger ( drivers/net/can/dev.c and include/linux/can/[dev.h|netlink.h] ).

Unfortunately i'm not an expert in USB programming and i don't have that
hardware - but if you need some ideas from the CAN driver peoples like
Wolfgang, questions are always welcome, e.g. on the socketcan-core ML:

http://developer.berlios.de/projects/socketcan

I don't think it's a big effort for people that know USB & CAN to clean up the
cpc-usb and make it a slim CAN netdev. Believe me, it took years to figure out
a sane userspace api for CAN interfaces, which is now provided by the netlink
interface ;-)

Best regards,
Oliver

