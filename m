From: Joshua Clayton <stillcompiling@gmail.com>
Subject: Re: [PATCH net-next V2 00/16] net: fec: cleanup and fixes
Date: Wed, 24 Feb 2016 18:52:44 -0800
Message-ID: <5514193.TiF8b6rKpj@diplodocus>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com,
	fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net,
	sergei.shtylyov@cogentembedded.com, arnd@arndb.de
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:34655 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbcBYCww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 21:52:52 -0500
Received: by mail-yw0-f193.google.com with SMTP id f6so1683244ywa.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 18:52:52 -0800 (PST)
In-Reply-To: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Troy,
I'm replying here instead of to a particular commit because several of
the commit messages seem inadequate.

The first line summaries all look good.

The descriptions should each also include the "user visible impact" of
the patch and the justification for it (i.e. why you made the change).

For instance, patch 3 doesn't include either what will change
 (nothing, I'm guessing?) or why we now pass in the structures
instead of a queue_id. 

You've also got a few (e.g. patch 9, patch 14) where the substance
of the patch is in the summary,

but missing from the message.

These kind of descriptions are very hard to review since the expression
is split between the subject of the email and the body of the email, which
are not close
together in some email programs.

Better to reiterate or elaborate on the summary in the message.
In patch 9, for instance, it would be more clear to say:

Move restart test to earlier in fec_txq() which saves one comparison. 

On Wednesday, February 24, 2016 05:36:43 PM Troy Kisky wrote:
> V2 is a rebase on top of johannes endian-safe patch and
> this set is only the next 16 patches.
> The testing for this series was done on a nitrogen6x.
> The base commit was
> commit f5461c27631672b9e95282812ee521c53f502eca
>     Merge branch 'dsa-pass-bridge-to-drivers'
> 
> Testing showed no change in performance.
> Testing used imx_v6_v7_defconfig + CONFIG_MICREL_PHY.
> The processor was running at 996Mhz.
> The following commands were used to get the transfer rates.
> 
> On an x86 ubunto system,
> iperf -s -i.5 -u
> 
> 
> On a nitrogen6x board, running via SD Card.
> I first stopped some background processes
> 
> stop cron
> stop upstart-file-bridge
> stop upstart-socket-bridge
> stop upstart-udev-bridge
> stop rsyslog
> stop dbus
> killall dhclient
> echo performance >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
> 
> taskset 0x2 iperf -c 192.168.0.201 -u -t60 -b500M -r
> 
> There is a branch available on github with this series, and the rest of
> my fec patches, for those who would like to test it.
> https://github.com:boundarydevices/linux-imx6.git branch net-next_master
> 
> 
> 
> Troy Kisky (16):
> SDCard
>  TX/RX
> 379/402	Before any patches
> 376/402  net: fec: only check queue 0 if RXF_0/TXF_0 interrupt is set
> 379/399  net: fec: pass rxq to fec_enet_rx_queue instead of queue_id
> 379/401  net: fec: pass txq to fec_enet_tx_queue instead of queue_id
> 389/409  net: fec: reduce interrupts
> 393/411  net: fec: split off napi routine with 3 queues
> 386/415  net: fec: don't clear all rx queue bits when just one is being checked
> 387/412  net: fec: set cbd_sc without relying on previous value
> 385/415  net: fec: eliminate calls to fec_enet_get_prevdesc
> 389/414  net: fec: move restart test for efficiency
> 386/412  net: fec: clear cbd_sc after transmission to help with debugging
> 387/415  net: fec: dump all tx queues in fec_dump
> 380/418  net: fec: detect tx int lost
> 385/417  net: fec: print more debug info in fec_timeout
> 388/417  net: fec: create subroutine reset_tx_queue
> 389/418  net: fec: call dma_unmap_single on mapped tx buffers at restart
> 381/414  net: fec: don't set cbd_bufaddr unless no mapping error
> 
>  drivers/net/ethernet/freescale/fec.h      |   7 +-
>  drivers/net/ethernet/freescale/fec_main.c | 420 ++++++++++++++++--------------
>  2 files changed, 224 insertions(+), 203 deletions(-)
> 
> 

Hope this helps,
Joshua

P.S I'm a little confused, as I came looking for a v3 of the first 8 patches
and found these instead. I'll try to give your first 8 a look when they show up.
