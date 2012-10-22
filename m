From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Bug#690845: ethtool: incorrect WoL detection on Broadcom NX
 II rev < 12
Date: Mon, 22 Oct 2012 15:54:19 -0700
Message-ID: <1350946459.8764.145.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <20121018134717.9579.22997.reportbug@palomino.museglobal.com>
 <1350570748.26833.102.camel@deadeye.wl.decadent.org.uk>
 <CAG2Wgfee=qsiUhAk5reYTypcOZL0kM5A58J+LjB1wuQ_k9FrfA@mail.gmail.com>
 <1350610209.22276.6.camel@deadeye.wl.decadent.org.uk>
 <1350675530.8764.131.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <CAG2Wgfdn52R2FYh77-2ZHCFVwe8d0MOv_4but6aOsU50jF-+Lg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: 690845@bugs.debian.org, netdev <netdev@vger.kernel.org>
To: "Teodor MICU" <mteodor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3413 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932215Ab2JVWyd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 18:54:33 -0400
In-Reply-To: <CAG2Wgfdn52R2FYh77-2ZHCFVwe8d0MOv_4but6aOsU50jF-+Lg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-22 at 10:52 +0300, Teodor MICU wrote:
> 08:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708
> Gigabit Ethernet (rev 11)

It is 5708 B1, and due to some hardware limitations, ethtool initiated
WoL is not supported.  Here's the code fragment in bnx2.c:

	if ((CHIP_ID(bp) == CHIP_ID_5708_A0) ||
	    (CHIP_ID(bp) == CHIP_ID_5708_B0) ||
	    (CHIP_ID(bp) == CHIP_ID_5708_B1) ||
	    !(REG_RD(bp, BNX2_PCI_CONFIG_3) & BNX2_PCI_CONFIG_3_VAUX_PRESET)) {
		bp->flags |= BNX2_FLAG_NO_WOL;
		bp->wol = 0;
	}
