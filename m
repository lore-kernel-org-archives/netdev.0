From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 2/4] sh_eth: Fix RX recovery on R-Car in case of RX
 ring underrun
Date: Fri, 27 Feb 2015 23:20:35 +0300
Message-ID: <54F0D193.4000807@cogentembedded.com>
References: <1424959937.4444.12.camel@xylophone.i.decadent.org.uk> <1424960348.4444.19.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: Ben Hutchings <ben.hutchings@codethink.co.uk>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:44098 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753437AbbB0UUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 15:20:40 -0500
Received: by lams18 with SMTP id s18so19713205lam.11
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 12:20:38 -0800 (PST)
In-Reply-To: <1424960348.4444.19.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/26/2015 05:19 PM, Ben Hutchings wrote:

> In case of RX ring underrun (RDE), we attempt to reset the software
> descriptor pointers (dirty_rx and cur_rx) to match where the hardware
> will read the next descriptor from, as that might not be the first
> dirty descriptor.  This relies on reading RDFAR, but that register
> doesn't exist on all supported chips - specifically, not on the R-Car
> chips.  This will result in unpredictable behaviour on those chips
> after an RDE.

> Make this pointer reset conditional and assume that it isn't needed on
> the R-Car chips.  This fix also assumes that RDFAR is never exposed at
> offset 0 in the memory map - this is currently true, and a subsequent
> commit will fix the ambiguity between offset 0 and no-offset in the
> register offset maps.

> Fixes: 79fba9f51755 ("net: sh_eth: fix the rxdesc pointer when rx ...")
> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
> ---
> I was able to trigger RDE by adding a udelay(10) to the loop in
> sh_eth_rx() (limiting RX to <100,000 pps) and sending minimum size
> frames with pktgen (~160,000 pps at 100M).  The RDE was recorded in the
> netdev stats.  After the RDE and recover I could still pass traffic
> successfully so no extra code appears to be needed for this chip.

    Thank you for at last tackling this; it was on my agenda for a long time...

WBR, Sergei
