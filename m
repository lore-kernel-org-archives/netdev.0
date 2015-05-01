From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC] r8169 DMA failure with iommu=off
Date: Fri, 1 May 2015 14:12:36 +0200
Message-ID: <20150501121236.GA13214@electric-eye.fr.zoreil.com>
References: <20150429165813.5d64daf0@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@Brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49321 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbbEAMMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 08:12:41 -0400
Content-Disposition: inline
In-Reply-To: <20150429165813.5d64daf0@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemming@Brocade.com> :
> This only fixes the Rx side, what about Tx?
> 
> I think maybe just removing the whole use_dac flag completely ?

Something simple would be welcome but I doubt it should be that simple.

The problems that the use_dac comment (MODULE_PARM_DESC) relates to
are 2003 ~ 2004, plain old PCI 8169 stuff. I see no problem exchanging
the use_dac test for something else (Config2.BIT(3) test for bus width
or old PCI chipsets blacklist).

I lack explicit reports to tell if high dma is safe with the PCI-E
chipsets but it's worth testing. The DAC bit in the CPlusCmd register
is indirectly documented in my old 8168c datasheet through the 64 bit
address capable bit of the MSI message control word (it's missing in
the section dedicated to the CPlusCmd register :o/). Expect it to
initially mirror some eeprom value.

Other than that I am mostly unqualified when it comes to high DMA paths
in the upper parts of the transmit stack.

-- 
Ueimor
