From: Christoph Fritz <chf.fritz@googlemail.com>
Subject: Re: usbnet: smsc95xx: fix link detection for disabled
 autonegotiation
Date: Thu, 26 May 2016 13:01:31 +0200
Message-ID: <1464260491.2726.11.camel@googlemail.com>
References: <1464228407.5421.34.camel@googlemail.com>
	 <20160526023120.GG21924@lunn.ch>
Reply-To: chf.fritz@googlemail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36187 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627AbcEZLBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 07:01:34 -0400
Received: by mail-wm0-f66.google.com with SMTP id q62so4226215wmg.3
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 04:01:33 -0700 (PDT)
In-Reply-To: <20160526023120.GG21924@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-26 at 04:31 +0200, Andrew Lunn wrote:
> On Thu, May 26, 2016 at 04:06:47AM +0200, Christoph Fritz wrote:
> > To detect link status up/down for connections where autonegotiation is
> > explicitly disabled, we don't get an irq but need to poll the status
> > register for link up/down detection.
> > This patch adds a workqueue to poll for link status.
> 
> Did you consider using the phylib? It probably does the needed polling
> already, and it looks like the functions needed to implement an MDIO
> bus are already in place.

smsc95xx supports a relative wide range of PHYs which I don't have
access to in regard of testing. So I prefer the least invasive one (with
this patch) as mostly all of the other usbnet drivers do.

A merge to phylib while paying attention to all the suspend modes and
testing the wide range of PHYs would surely be the right thing to do.

Any thoughts on that?

Thanks
  -- Christoph
