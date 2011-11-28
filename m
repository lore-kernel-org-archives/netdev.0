From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/2] tg3: Scale back code that modifies MRRS
Date: Mon, 28 Nov 2011 19:53:56 +0000
Message-ID: <1322510036.26733.12.camel@bwh-desktop>
References: <1322509264-19636-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27407 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754100Ab1K1TyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 14:54:00 -0500
In-Reply-To: <1322509264-19636-3-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-28 at 11:41 -0800, Matt Carlson wrote:
> Tg3 normally gets a performance boost by increasing the PCI Maximum Read
> Request Size (MRRS) to 4k.  Unfortunately, this is causing some problems
> on particular hardware platforms.  This patch removes all code that
> modifies the MRRS except for one case.
> 
> As part of a solution to fix an internal FIFO problem on the 5719, the
> driver artificially capped the MRRS to 2k for the entire 5719, and later
> 5720, ASIC revs.  This was overly aggressive and only really needed to
> be done for the 5719 A0.  In the spirit of the rest of this patch, the
> driver will only reprogram the MRRS for this device if the value exceeds
> the 2k cap.
[...]

It may be better to do this as a PCI quirk, so that the generic MPS/MRRS
configuration code has this information.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
