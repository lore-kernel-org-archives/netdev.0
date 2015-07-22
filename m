From: Duan Andy <fugang.duan@freescale.com>
Subject: RE: A Regression between v4.2-rc2 and v4.2-rc3
Date: Wed, 22 Jul 2015 06:58:10 +0000
Message-ID: <BLUPR03MB373807C6285A5A9D43CADDDF5830@BLUPR03MB373.namprd03.prod.outlook.com>
References: <20150722054445.GA3651@shlinux2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>
To: Peter Chen <Peter.Chen@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0136.outbound.protection.outlook.com ([157.56.111.136]:54417
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755681AbbGVG6M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 02:58:12 -0400
In-Reply-To: <20150722054445.GA3651@shlinux2>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Chen <peter.chen@freescale.com> Sent: Wednesday, July 22, 2015 1:45 PM
> To: netdev@vger.kernel.org
> Cc: Andrew Lunn; Duan Fugang-B38611; David S. Miller
> Subject: A Regression between v4.2-rc2 and v4.2-rc3
> 
> Hi List,
> 
> I run out a kernel oops [2] for nfsroot at several imx6 boards when
> rebase to v4.2-rc3, after revert below patch [1], it is ok.
> This patch is just adding runtime pm for ipg clock, I am wonder why it
> takes as a bug fix.
> 
> [1]
> commit 6c3e921b18edca290099adfddde8a50236bf2d80
> Author: Andrew Lunn <andrew@lunn.ch>
> Date:   Mon Jul 6 20:34:55 2015 +0200
> 
>     net: fec: Ensure clocks are enabled while using mdio bus
> 
>     When a switch is attached to the mdio bus, the mdio bus can be used
>     while the interface is not open. If the IPG clock is not enabled,
> MDIO
>     reads/writes will simply time out.
> 
>     Add support for runtime PM to control this clock. Enable/disable this
>     clock using runtime PM, with open()/close() and mdio read()/write()
>     function triggering runtime PM operations. Since PM is optional, the
>     IPG clock is enabled at probe and is no longer modified by
>     fec_enet_clk_enable(), thus if PM is not enabled in the kernel, it is
>     guaranteed the clock is running when MDIO operations are performed.
> 
>     Signed-off-by: Andrew Lunn <andrew@lunn.ch>
>     Acked-by: Fugang Duan <B38611@freescale.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 

The patch was reverted in last week.

Regards,
Andy
