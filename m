From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-next 2/2] tg3: Scale back code that modifies
 MRRS
Date: Mon, 28 Nov 2011 14:45:58 -0800
Message-ID: <20111128224558.GA20447@mcarlson.broadcom.com>
References: <1322509264-19636-3-git-send-email-mcarlson@broadcom.com>
 <1322510036.26733.12.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2675 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754975Ab1K1WpU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 17:45:20 -0500
In-Reply-To: <1322510036.26733.12.camel@bwh-desktop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2011 at 11:53:56AM -0800, Ben Hutchings wrote:
> On Mon, 2011-11-28 at 11:41 -0800, Matt Carlson wrote:
> > Tg3 normally gets a performance boost by increasing the PCI Maximum Read
> > Request Size (MRRS) to 4k.  Unfortunately, this is causing some problems
> > on particular hardware platforms.  This patch removes all code that
> > modifies the MRRS except for one case.
> > 
> > As part of a solution to fix an internal FIFO problem on the 5719, the
> > driver artificially capped the MRRS to 2k for the entire 5719, and later
> > 5720, ASIC revs.  This was overly aggressive and only really needed to
> > be done for the 5719 A0.  In the spirit of the rest of this patch, the
> > driver will only reprogram the MRRS for this device if the value exceeds
> > the 2k cap.
> [...]
> 
> It may be better to do this as a PCI quirk, so that the generic MPS/MRRS
> configuration code has this information.

If at all possible, I'd rather do that as a follow-on patch.  This patch
fixes a critical problem that is blocking a lot of testing.
