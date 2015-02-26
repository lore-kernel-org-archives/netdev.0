From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: [PATCH net 3/4] Revert "sh_eth: Enable Rx descriptor word 0
 shift for r8a7790"
Date: Thu, 26 Feb 2015 16:14:51 +0000
Message-ID: <1424967291.4444.30.camel@xylophone.i.decadent.org.uk>
References: <1424959937.4444.12.camel@xylophone.i.decadent.org.uk>
	 <1424960474.4444.21.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:38761 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932243AbbBZQO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 11:14:56 -0500
In-Reply-To: <1424960474.4444.21.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-26 at 14:21 +0000, Ben Hutchings wrote:
> This reverts commit fd9af07c3404ac9ecbd0d859563360f51ce1ffde.
> 
> The hardware manual states that the frame error and multicast bits are
> copied to bits 9:0 of RD0, not bits 25:16.  I've tested that this is
> true for RFS1 (CRC error), RFS3 (frame too short), RFS4 (frame too
> long) and RFS8 (multicast).
[...]

This behaviour might of course be dependent on the revision of the chip.
I didn't find a chip ID register in the manual, but I found the recent
patch "ARM: shmobile: Add function to get SoCs revision data for R-Car
Gen2".  With that patch, /proc/cpuinfo on my test system shows:

Hardware        : Generic R8A7790 (Flattened Device Tree)
Revision        : 0020
Serial          : 0000000000000000

Ben.
