From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH] r8169: remember WOL preferences on driver load
Date: Thu, 15 Aug 2013 14:09:31 +0800
Message-ID: <07AFF12D81984B438F6986A677F18C32@realtek.com.tw>
References: <1376425145-30142-1-git-send-email-lekensteyn@gmail.com> <20130813212843.GB5635@electric-eye.fr.zoreil.com> <5823402.G5n4G2k0Uv@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, 'nic_swsd' <nic_swsd@realtek.com>
To: 'Peter Wu' <lekensteyn@gmail.com>,
	'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:58476 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327Ab3HOGJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 02:09:44 -0400
In-Reply-To: <5823402.G5n4G2k0Uv@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu [mailto:lekensteyn@gmail.com] 
> Sent: Wednesday, August 14, 2013 8:57 PM
> To: Francois Romieu
> Cc: netdev@vger.kernel.org; nic_swsd; Hayeswang
> Subject: Re: [PATCH] r8169: remember WOL preferences on driver load
> 
> On Tuesday 13 August 2013 23:28:43 Francois Romieu wrote:
> > > The r8168 vendor driver used to write to both Config1 and 
> Config5, but
> > > in recent versions, this is commented out. Here we keep 
> writing PMEnable
> > > to Config1 because there may be older chips where 
> PMEnable is not sticky.
> > 
> > <sneak regression paranoia>
> > Please include the bits you want to keep in the "&" mask.
> > </sneak regression paranoia>
> 
> I previously tried:
> 
>     RTL_W8(Config5, RTL_R8(Config5) & (BWF | MWF | UWF | 
> LanWake | PMEStatus));

I think this way is better and safe.

> but then I realized that the Realtek r8168 vendor driver does 
> not touch this 
> register on load. The bits not included in the above mask are 
> 2, 3 and 7. On 
> most datasheets for recent hardware, these are marked reserved.

Some settings would be in rtl8168_hw_start() for different chips.
We sure only correct bit would be enabled.

The simple way is to clear bit 2, 3 and 7 for all chips. Or set desired
bit which you want.

 
Best Regards,
Hayes
