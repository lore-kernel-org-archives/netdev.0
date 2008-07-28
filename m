From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch inside] kernel crash, RTL8101E [10ec:8136]
Date: Mon, 28 Jul 2008 20:40:48 +0200
Message-ID: <20080728184048.GA21552@electric-eye.fr.zoreil.com>
References: <200807271904.m6RJ4G2Y013513@post.webmailer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mario Limonciello <Mario_Limonciello@Dell.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>, netdev@vger.kernel.org
To: c4p7n1@capitanio.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:57321 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755600AbYG1SlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 14:41:03 -0400
Content-Disposition: inline
In-Reply-To: <200807271904.m6RJ4G2Y013513@post.webmailer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(removed Linus from the Cc:)

c4p7n1@capitanio.org <c4p7n1@capitanio.org> :
[...]
> Boiling hot Sunday. So I decided to spend some time for digging to this issue.
> I see some parts that may not behave as intended. Could someone take a care?  
> 
> Fist I thought that the pci system and the subsystem disagrees about the
> chip-set:
[...]
> Subsystem: Toshiba America Info Systems Unknown device [1179:ff64]
> means Realtek RTL8102E Family PCI-E Fast Ethernet NIC (NDIS 6.0)
> [Toshiba America Information Systems] 1179:ff64 rev 02
[...]
> The pci entry just confuse people, the correct message were something like
> Realtek Semiconductor Co., Ltd. RTL81xxx Ethernet controller

10ec:8136 covers the 8101 and the 8102, as expected.

> Everything depending on this information may break, right?
> drivers/net/r8169.c:166:{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,0x8136),0,0,RTL_CFG_2 },

I do not get it. Where do you see a breakage ?

[...]
> Checking the web for the differences btw RTL8102E and RTL8101E:
> the RTL8102E claims to support receive-side scaling, is this implemented
> somewhere in linux (aka NAPI?) ?

1. RSS is available with Linux.
2. RSS is not related in any way or shape with NAPI.
3. RSS is not implemented in Realtek's driver yet.

> Can miss-detecting have a bad side-effects?

Some users have been turned into giant walking mushrooms.

Not sure if they were comestible or not though.

> RTL8102E offers an option for non-EEPROM (=OTP) design. Can the driver
> break the hardware ?

The driver is not supposed to break the hardware.

[...]
> > Can you give the completely untested patch below a try (say, against
> > 2.6.26 or more) ?
> This works.

Thanks.

What does ethtool report for this device ? Does it still claim gigabit
to be supported ?

-- 
Ueimor
