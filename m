From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net/r8169: Update the new parser for the new firmware
Date: Wed, 15 Jun 2011 01:04:38 +0200
Message-ID: <20110614230438.GA1746@electric-eye.fr.zoreil.com>
References: <1307956594-1248-1-git-send-email-hayeswang@realtek.com> <20110613143241.GA1579@electric-eye.fr.zoreil.com> <AAB6D1CA92564062BD4DA23B485C6B55@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50652 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752398Ab1FNXRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 19:17:10 -0400
Content-Disposition: inline
In-Reply-To: <AAB6D1CA92564062BD4DA23B485C6B55@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
[...]
> I want to keep the old firmware used by the old paser. The old paser cannot
> use the new firmware and the new paser cannot use the old firmware, so I
> separate them.

Two points:
1. it can be done anyway. See below.
2. I agree with a different name, thoug only in the linux-firmware git
   repository and in the local filesystem firmware directory. Naming the
   relevant file for FIRMWARE_8168D_1 something like "rtl8168d-1[_-.]x.y.z"
   in the linux-firmware repository exhibits some self documenting virtues.
   rtl8168d-1.fw only needs to link to the firmware of the day. On the other
   hand, retrieving FIRMWARE_8168D_1 through rtl8168d-3.fw - and tomorrow
   through rtl8168d-7.fw ? - is imho convoluted and mildly nice to maintain
   when there are FIRMWARE_8168D_1, FIRMWARE_8168D_2 etc.

[...]
> > Imho the new firmware format could include some specific 
> > string so that the driver can identify the new firmware 
> > format and fallback to the old format otherwise. Any fixed 
> > magic prefix would be enough as the new format mandates the 
> > version information.
> > 
> > This way Linus's test machine won't risk of breaking 
> > (again...) if he builds a new kernel without updating the 
> > firmware at the same time.
> > 
> 
> I plan to let the old paser loads the old firmware and the new paser loads the
> new firmware. If you build the new kernel without updating the firmware, you
> just load no firmware because the new firmware doesn't exist. However, it is
> more dangerous for the old paser to load the new firmware. That is why I
> create the new ones, not replace the existing files.

Regarding the old driver and new firmware combination, it is possible to
design the new firmware format so that it gets ignored by the old driver.
If the new firmware format starts with a huge PHY_SKIPN instruction,
the old parser will not use it and will emit an "Out of range of firmware"
error message. Add a magic prefix and the new driver has some decent
heuristic to figure if it handles a new / old format firmware.

Regarding the new driver and old firmware combination, why should the new
driver be allowed to refuse working with the old firmware if the old firmware
is not known broken ?

-- 
Ueimor
