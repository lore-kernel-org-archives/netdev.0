From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2.6.29-rc] usbnet: allow type check of devdbg arguments
 in non-debug build
Date: Mon, 19 Jan 2009 17:57:30 -0800 (PST)
Message-ID: <20090119.175730.262402885.davem@davemloft.net>
References: <1221493664-544-1-git-send-email-steve.glendinning@smsc.com>
	<200901162319.44255.david-b@pacbell.net>
	<20090119.171200.235073814.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com,
	ian.saturley@smsc.com, jeff@garzik.org
To: david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50971
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759488AbZATB53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 20:57:29 -0500
In-Reply-To: <20090119.171200.235073814.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 19 Jan 2009 17:12:00 -0800 (PST)

> From: David Brownell <david-b@pacbell.net>
> Date: Fri, 16 Jan 2009 23:19:44 -0800
> 
> > Improve usbnet's devdbg to always type-check diagnostic arguments,
> > like dev_dbg (device.h).  This makes no change to the resulting size of
> > usbnet modules.
> > 
> > Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> > Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
> 
> Applied, thanks.

I have to back this out, it breaks the build:

drivers/net/wireless/rndis_wlan.c: In function 'rndis_translate_scan':
drivers/net/wireless/rndis_wlan.c:1664: error: 'usbdev' undeclared (first use in this function)
drivers/net/wireless/rndis_wlan.c:1664: error: (Each undeclared identifier is reported only once
drivers/net/wireless/rndis_wlan.c:1664: error: for each function it appears in.)
make[3]: *** [drivers/net/wireless/rndis_wlan.o] Error 1
make[3]: *** Waiting for unfinished jobs....
make[2]: *** [drivers/net/wireless] Error 2
make[2]: *** Waiting for unfinished jobs....

I bet there are other similar gremlins like this in the tree.
