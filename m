From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: netlink support for bus-error reporting and
 counters
Date: Wed, 3 Mar 2010 16:47:20 -0800
Message-ID: <20100303164720.1890c9f5@nehalam>
References: <4B8390D7.5010409@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37657 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752306Ab0CDArb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 19:47:31 -0500
In-Reply-To: <4B8390D7.5010409@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Feb 2010 09:24:55 +0100
Wolfgang Grandegger <wg@grandegger.com> wrote:

> This patch uses the new features of the kernel's netlink CAN interface
> making the bus-error reporting configurable and allowing to retrieve
> the CAN TX and RX bus error counters via netlink interface. Here is the
> output of my test session showing how to use them:
> 
> # ip link set can0 up type can bitrate 500000 berr-reporting on
> # ip -d -s link show can0
> 2: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
>     link/can
>     can <BERR-REPORTING> state ERROR-PASSIVE (berr-counter tx 128 rx 0) restart-ms 0
>                               CAN bus error counter values ^^^^^^^^^^^
>     bitrate 500000 sample-point 0.875
>     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
>     sja1000: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>     clock 8000000
>     re-started bus-errors arbit-lost error-warn error-pass bus-off
>     0          54101      0          1          1          0
>     RX: bytes  packets  errors  dropped overrun mcast
>     432808     54101    54101   0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     0          0        0       0       0       0
> 
> # ifconfig can0 down
> # ip link set can0 up type can berr-reporting off
> # candump -t d any,0:0,#FFFFFFFF
>  (0.000000)  can0  20000004  [8] 00 08 00 00 00 00 60 00   ERRORFRAME
>  (0.000474)  can0  20000004  [8] 00 20 00 00 00 00 80 00   ERRORFRAME
>                                                    ^^ ^^
> 						    \  \___ rxerr
> 						     \_____ txerr
> 
> Furthermore, the missing support for one-shot mode has been added.
> 
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

Applied, I had already got the header file changes as part of the
net-next header file resync.
