From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] usbnet: drop unneeded check for NULL
Date: Thu, 6 Sep 2012 09:52:55 +0200
Message-ID: <20120906075255.GC2550@netboy.at.omicron.at>
References: <20120904.123740.1915830868205918256.davem@davemloft.net>
 <20120905044712.GA2284@netboy.at.omicron.at>
 <2037108.ZemStJh9zr@linux-lqwf.site>
 <20120905.125016.2259674613767082102.davem@davemloft.net>
 <1346883275.5325.28.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, oneukum@suse.de,
	netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:64466 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423Ab2IFHxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 03:53:06 -0400
Received: by wibhr14 with SMTP id hr14so1103501wib.1
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 00:53:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1346883275.5325.28.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 05, 2012 at 11:14:35PM +0100, Ben Hutchings wrote:
> 
> Perhaps the skb_tx_timestamp() call should be moved below the
> 'if (info->tx_fixup)' block, at which point skb is definitely non-null.

No, that block shuffles the packet alignment all around, and spoils
any code which needs to match packets with time stamps.

> It doesn't look like cdc-ncm will provide useful timestamps either way.

But it is not the only user of this code. Furthermore, the PHY driver
will want a chance to provide a HW time stamp in any case.

Thanks,
Richard
