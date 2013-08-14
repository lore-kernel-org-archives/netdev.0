From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: [PATCH] r8169: remember WOL preferences on driver load
Date: Wed, 14 Aug 2013 14:56:53 +0200
Message-ID: <5823402.G5n4G2k0Uv@al>
References: <1376425145-30142-1-git-send-email-lekensteyn@gmail.com> <20130813212843.GB5635@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:33074 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932369Ab3HNM46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 08:56:58 -0400
Received: by mail-wi0-f172.google.com with SMTP id hj13so1905114wib.11
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 05:56:57 -0700 (PDT)
In-Reply-To: <20130813212843.GB5635@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 13 August 2013 23:28:43 Francois Romieu wrote:
> > The r8168 vendor driver used to write to both Config1 and Config5, but
> > in recent versions, this is commented out. Here we keep writing PMEnable
> > to Config1 because there may be older chips where PMEnable is not sticky.
> 
> <sneak regression paranoia>
> Please include the bits you want to keep in the "&" mask.
> </sneak regression paranoia>

I previously tried:

    RTL_W8(Config5, RTL_R8(Config5) & (BWF | MWF | UWF | LanWake | PMEStatus));

but then I realized that the Realtek r8168 vendor driver does not touch this 
register on load. The bits not included in the above mask are 2, 3 and 7. On 
most datasheets for recent hardware, these are marked reserved.

For RTL8100C(L) (datasheet 1.3 from 2007), RTL8139D(L) (datasheet 1.3 from 
2005) and RTL8101L (1.6 from 2008)
- bit 2 is Link Down Power Saving mode (1=disable, 0=enable; loaded from 
EEPROM on RTL8139D(L))
- bit 3 is FIFOAddrPtr (internal use for testing FIFO SRAM, default 0)
- bit 7 is reserved

I'll let Hayes judge which approach is more appropriate.

Regards,
Peter
