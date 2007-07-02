From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: sky2 hangs without any messages
Date: Mon, 2 Jul 2007 11:17:37 +0100
Message-ID: <6278d2220707020317l2ccf660fh9f188b53c68917cf@mail.gmail.com>
References: <6278d2220707020315q7c3df1cci5c7bb52316ad6081@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:21969 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbXGBKRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 06:17:39 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1458538wxd
        for <netdev@vger.kernel.org>; Mon, 02 Jul 2007 03:17:38 -0700 (PDT)
In-Reply-To: <6278d2220707020315q7c3df1cci5c7bb52316ad6081@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Tino Keitel <tino.keitel@tikei.de> wrote:
>> in the last 2 days, I had 2 outages of the NIC of my Mac mini Core Duo.
>> I checked the kernel log but I found nothing sky2 related. After
>> reloading the module, the interface worked again.

> There is a reproducible hang (due to missed IRQ) in sky2.  It is more reproducible
> with slower CPU's like Mac Mini.

This feels like the same problem I hit once every ~2 days on my server
platform or laptop [1]: both Yukon-ECs, rev 1 and 2, running NFSv4
over TCP over a gig-e switch, ia32, PCI-E.

Observations:

1. problem happens with both rev-1 and 2 Yukon-ECs, so less likely a silicon bug
2. reproducible with 1500 MTU on both ends
3. reproducible with and without receive offloading disabled (ie
'ethtool -K gig0 rx off') [check with tx offload too?]
4. reproducible with two different gig-e switches and different cables
5. reproducible with MSI interrupts [check with legacy interrupts?]

Is there anything that I can do to help debug this missing IRQ hang?
I'm thinking of moving to the vendor driver [2] to see if the issue is
entirely avoidable in software.

Thanks,
  Daniel

--- [1]

sky2 0000:02:00.0: v1.14 addr 0xd6000000 irq 16 Yukon-EC (0xb6) rev 2
sky2 gig0: addr 00:16:b6:70:d8:3d
sky2 gig0: enabling interface
sky2 gig0: ram buffer 48K
sky2 gig0: Link is up at 1000 Mbps, full duplex, flow control both
<NFS hang observed>
NETDEV WATCHDOG: gig0: transmit timed out
sky2 gig0: tx timeout
sky2 gig0: transmit ring 424 .. 401 report=427 done=427
sky2 gig0: disabling interface
sky2 gig0: enabling interface
sky2 gig0: ram buffer 48K
sky2 gig0: Link is up at 1000 Mbps, full duplex, flow control both
<NFS resumes after a few minutes>

$ grep gig0 /proc/interrupts
218:      27297          0   PCI-MSI-edge      gig0

--- [2]

http://www.syskonnect.de/e_en/products/adapters/pcie_server/sk-9exx/software/linux/driver/install-8_31.tar.bz2
-- 
Daniel J Blueman
