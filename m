From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: tg3: link is permanently down after ifdown and ifup
Date: Thu, 19 Nov 2009 18:08:37 +0200
Message-ID: <4B056D85.5010904@embedded-sol.com>
References: <4B056158.5060104@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:55722 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752931AbZKSQI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 11:08:29 -0500
In-Reply-To: <4B056158.5060104@embedded-sol.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The problem goes away if I remove the call to

tg3_set_power_state(tp, PCI_D3hot);

from tg3_close().

Some relevant stuff from dmesg:

pci 0002:05:00.0: PME# supported from D3hot D3cold
pci 0002:05:00.0: PME# disabled
tg3.c:v3.102 (September 1, 2009)
tg3 0002:05:00.0: enabling device (0000 -> 0002)
tg3 0002:05:00.0: PME# disabled
tg3 mdio bus: probed
eth2: Tigon3 [partno(BCM57760) rev 57780001] (PCI Express) MAC address 
00:10:18:00:00:00
eth2: attached PHY driver [Broadcom BCM57780] (mii_bus:phy_addr=500:01)
eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
eth2: dma_rwctrl[76180000] dma_mask[64-bit]

Is my problem related to hardware or it's a tg3 driver bug ?

Thanks a lot.

Felix.

Felix Radensky wrote:
> Hi,
>
> I have a problem with tg3 driver on a custom MPC8536 based board
> running linux-2.6.31, with tg3 and Broadcom phy drivers taken from
> linux-2.6.32-rc7. Broadcom NIC is BCM57760, phy is BCM57780.
>
> The problem I'm seeing is that the downing and interface leads to
> permanent link loss, even after interface is upped again. E.g, to
> reproduce the problem it is sufficient to run:
>
> modprobe tg3
> ifconfig eth2 up
> ifconfig eth2 down
> ifconfig eth2 up
>
> After ifdown PHY LEDs also go down and do not come back
> after ifup. Ethtool reports that no link is detected. After reloading
> the driver the link comes back.
>
> Am I the only one seeing this problem  ?
> Any help on fixing this is appreciated.
>
> Thanks a lot.
>
> Felix.
>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev


