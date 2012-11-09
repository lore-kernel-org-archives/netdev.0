From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Lower wake up time when phy enter lower mode
Date: Fri, 9 Nov 2012 15:07:19 +0000
Message-ID: <1352473639.3159.3.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAHrpEqSw8N4nN6Wgnu2z3tWS_CrGoPMbFj2wJjmDv2JPLW7cLg@mail.gmail.com>
	 <1352315183.2725.17.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAHrpEqQYXxADPrYd=TwqEPaecWt_yjgkivCR6iek9qk0z73WzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33793 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753527Ab2KIPHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 10:07:25 -0500
In-Reply-To: <CAHrpEqQYXxADPrYd=TwqEPaecWt_yjgkivCR6iek9qk0z73WzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-08 at 10:09 +0800, Frank Li wrote:
> 2012/11/8 Ben Hutchings <bhutchings@solarflare.com>:
> > On Wed, 2012-11-07 at 10:52 +0800, Frank Li wrote:
> >> Richard:
> >>
> >>           Recently, I found out the path delay will increase about
> >> 20us suddenly in something when connect two iMX6 board and Ethernet
> >> work on 1G mode.
> >>           The reason is that the PHY enter lower mode automatically
> >> when no package send and receive. It takes some time to recover and
> >> send out package by PHY but MAC think package have sent and sample
> >> time stamper.
> >>           Do you meet such case?  I can workaround it by two method
> >>                1. disable phy lower power feature.
> >>                2. add some dummy package before SYNC package.
> >
> > If this low power mode is related to EEE (Energy Efficient Ethernet)
> > then there are ethtool operations defined for configuring it, and you
> > could implement those.
> 
> Yes, it is phy specific, called smart EEE, which compatible with IEEE 802.3az
> and can be used in legacy MAC without EEE.
> 
> Do you have example about ethtool operations?

Look at the comments on struct ethtool_eee in <uapi/linux/ethtool.h>,
and the existing implementations:

drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
