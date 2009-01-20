From: David Brownell <david-b@pacbell.net>
Subject: Re: [patch 2.6.29-rc] usbnet: allow type check of devdbg arguments in non-debug build
Date: Mon, 19 Jan 2009 18:04:08 -0800
Message-ID: <200901191804.09004.david-b@pacbell.net>
References: <1221493664-544-1-git-send-email-steve.glendinning@smsc.com> <20090119.171200.235073814.davem@davemloft.net> <20090119.175730.262402885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com,
	ian.saturley@smsc.com, jeff@garzik.org,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp110.sbc.mail.gq1.yahoo.com ([67.195.14.95]:41909 "HELO
	smtp110.sbc.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751759AbZATCKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 21:10:50 -0500
In-Reply-To: <20090119.175730.262402885.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 19 January 2009, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 19 Jan 2009 17:12:00 -0800 (PST)
> 
> > From: David Brownell <david-b@pacbell.net>
> > Date: Fri, 16 Jan 2009 23:19:44 -0800
> > 
> > > Improve usbnet's devdbg to always type-check diagnostic arguments,
> > > like dev_dbg (device.h).  This makes no change to the resulting size of
> > > usbnet modules.
> > > 
> > > Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> > > Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
> > 
> > Applied, thanks.
> 
> I have to back this out, it breaks the build:
> 
> drivers/net/wireless/rndis_wlan.c: In function 'rndis_translate_scan':
> drivers/net/wireless/rndis_wlan.c:1664: error: 'usbdev' undeclared (first use in this function)
> drivers/net/wireless/rndis_wlan.c:1664: error: (Each undeclared identifier is reported only once
> drivers/net/wireless/rndis_wlan.c:1664: error: for each function it appears in.)
> make[3]: *** [drivers/net/wireless/rndis_wlan.o] Error 1
> make[3]: *** Waiting for unfinished jobs....
> make[2]: *** [drivers/net/wireless] Error 2
> make[2]: *** Waiting for unfinished jobs....
> 
> I bet there are other similar gremlins like this in the tree.

Maybe, but that's after all part of why we want this kind
of patch merged ... after the first gremlines are fixed!

In this case I'll guess this is the root cause of the bug:

#ifdef DEBUG
        struct usbnet *usbdev = netdev_priv(dev);
#endif

 
CC'd someone more involved in rndis_wlan than me ...

- Dave



