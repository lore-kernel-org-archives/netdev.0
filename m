From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V2 00/16] net: fec: cleanup and fixes
Date: Wed, 24 Feb 2016 17:36:43 -0700
Message-ID: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36767 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbcBYAkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 19:40:11 -0500
Received: by mail-pa0-f43.google.com with SMTP id yy13so21736745pab.3
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 16:40:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V2 is a rebase on top of johannes endian-safe patch and
this set is only the next 16 patches.
The testing for this series was done on a nitrogen6x.
The base commit was
commit f5461c27631672b9e95282812ee521c53f502eca
    Merge branch 'dsa-pass-bridge-to-drivers'

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



Troy Kisky (16):
SDCard
 TX/RX
379/402	Before any patches
376/402  net: fec: only check queue 0 if RXF_0/TXF_0 interrupt is set
379/399  net: fec: pass rxq to fec_enet_rx_queue instead of queue_id
379/401  net: fec: pass txq to fec_enet_tx_queue instead of queue_id
389/409  net: fec: reduce interrupts
393/411  net: fec: split off napi routine with 3 queues
386/415  net: fec: don't clear all rx queue bits when just one is being checked
387/412  net: fec: set cbd_sc without relying on previous value
385/415  net: fec: eliminate calls to fec_enet_get_prevdesc
389/414  net: fec: move restart test for efficiency
386/412  net: fec: clear cbd_sc after transmission to help with debugging
387/415  net: fec: dump all tx queues in fec_dump
380/418  net: fec: detect tx int lost
385/417  net: fec: print more debug info in fec_timeout
388/417  net: fec: create subroutine reset_tx_queue
389/418  net: fec: call dma_unmap_single on mapped tx buffers at restart
381/414  net: fec: don't set cbd_bufaddr unless no mapping error

 drivers/net/ethernet/freescale/fec.h      |   7 +-
 drivers/net/ethernet/freescale/fec_main.c | 420 ++++++++++++++++--------------
 2 files changed, 224 insertions(+), 203 deletions(-)

-- 
2.5.0
