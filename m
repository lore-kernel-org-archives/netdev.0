From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: [PATCH net-2.6 V2] tg3: Fix phylib locking strategy
Date: Mon, 16 Nov 2009 22:53:57 +0200
Message-ID: <4B01BBE5.9060105@embedded-sol.com>
References: <1254801692.18507@xw6200>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	andy@greyhouse.net
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:37320 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbZKPWCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 17:02:37 -0500
In-Reply-To: <1254801692.18507@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Matt

Matt Carlson wrote:
> O.K.  Here is the latest version.  Felix, can you verify your problem
> is solved with this patch?
>
> ---
>
> Felix Radensky noted that chip resets were generating stack trace dumps.
> This is because the driver is attempting to acquire the mdio bus mutex
> while holding the tp->lock spinlock.  The fix is to change the code such
> that every phy access takes the tp->lock spinlock instead.
>
>   
Sorry for a very long delay, I didn't have access to hardware until today.
Your patch fixes initial problem I've reported, but I have a different
problem now, maybe it's related. It is 100% reproducible by the following
sequence

modprobe tg3
ifconfig eth2 up
ifconfig eth2 down
ifconfig eth2 up

As a result, link is not recognized after third invocation of ifconfig,
although network cable is plugged in. Below are relevant kernel messages.
Reloading tg3 driver fixes the problem.

tg3.c:v3.102 (September 1, 2009)
tg3 0002:05:00.0: PME# disabled
tg3 mdio bus: probed
eth2: Tigon3 [partno(BCM57760) rev 57780001] (PCI Express) MAC address 
00:10:18:00:00:00
eth2: attached PHY driver [Broadcom BCM57780] (mii_bus:phy_addr=500:01)
eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
eth2: dma_rwctrl[76180000] dma_mask[64-bit]
tg3 0002:05:00.0: PME# disabled
tg3: eth2: Link is down.
tg3: eth2: Link is up at 1000 Mbps, full duplex.
tg3: eth2: Flow control is on for TX and on for RX.
tg3: eth2: Link is down.
tg3 0002:05:00.0: PME# disabled
tg3: eth2: Link is down.

Thanks.

Felix.

