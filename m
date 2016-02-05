From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V2 0/8] net: fec: cleanup/fixes
Date: Fri,  5 Feb 2016 14:52:42 -0700
Message-ID: <1454709170-19527-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net, arnd@arndb.de,
	Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:32780 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbcBEVzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 16:55:05 -0500
Received: by mail-pf0-f177.google.com with SMTP id w123so75565382pfb.0
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 13:55:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


V2 is a rebase on top of johannes endian-safe patch and
is only the 1st eight patches.
The testing for this series was done on a nitrogen6x.
The base commit was
commit b45efa30a626e915192a6c548cd8642379cd47cc
    Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net

Testing showed no change in performance.
Testing used imx_v6_v7_defconfig + CONFIG_MICREL_PHY.
The processor was running at 996Mhz.
The following commands were used to get the transfer rates.

On an x86 ubunto system,
iperf -s -i.5 -u


On a nitrogen6x board, running via SD Card.
I first stopped some background processes

stop cron
stop upstart-file-bridge
stop upstart-socket-bridge
stop upstart-udev-bridge
stop rsyslog
stop dbus
killall dhclient
echo performance >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

taskset 0x2 iperf -c 192.168.0.201 -u -t60 -b500M -r

There is a branch available on github with this series, and the rest of
my fec patches, for those who would like to test it.
https://github.com:boundarydevices/linux-imx6.git branch net-next_master



Troy Kisky (8):
SDCard
 TX/RX
378/405  before any patches
379/407  net: fec: stop the "rcv is not +last, " error messages
378/405  net: fec: fix rx error counts
379/396  net: fec: fix fec_enet_get_free_txdesc_num
379/403  net: fec: add struct bufdesc_prop
390/396  net: fec: add variable reg_desc_active to speed things up
388/396  net: fec: don't disable FEC_ENET_TS_TIMER interrupt
382/403  net: fec: don't transfer ownership until descriptor write is complete
378/403  net: fec: improve error handling

 drivers/net/ethernet/freescale/fec.h      |  38 ++-
 drivers/net/ethernet/freescale/fec_main.c | 396 ++++++++++++++----------------
 2 files changed, 196 insertions(+), 238 deletions(-)

-- 
2.5.0
