From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH v2 1/6] net: dsa: Use delayed work instead of timer+work
 for polling
Date: Thu, 29 Oct 2015 15:10:11 +0100
Message-ID: <563228C3.6010501@baylibre.com>
References: <56321DA1.4060304@baylibre.com> <20151029135156.GQ2307@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:34337 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980AbbJ2OKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 10:10:19 -0400
Received: by wmff134 with SMTP id f134so25054930wmf.1
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 07:10:17 -0700 (PDT)
In-Reply-To: <20151029135156.GQ2307@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/2015 02:51 PM, Andrew Lunn wrote:
> On Thu, Oct 29, 2015 at 02:22:41PM +0100, Neil Armstrong wrote:
> Hi Neil, Frode
> 
> I assume you have see:
> 
> http://permalink.gmane.org/gmane.linux.network/380777
> 
> which is now in net-next.
> 
> The only driver making use of poll_link is mv88e6060.c. The argument
> from removing it from the other mv88e6xxx drivers is that it is not
> needed. The phylib will be polling the phys and looking for state
> changes. mv88e6060.c implements phy_read() and phy_write() so it
> should also allow the use of phylib.
> 
> Could you try 6060 without .poll_link. If that works, we should be
> able to remove all this code, rather than fix it up.
> 
>      Andrew
> 
Hi Andrew,

Thanks for the hint, I will test this, but while reviewing the datasheet,
the port 5 has no PHY, so must only be used as cpu port.

I also have another patchset which fixes 2 setup registers writes and
adds a shiny new mv88e6060.h based on mv88e6xxx.h.
I think the removal of the poll_link in mv88e6060 should be in this patchset.

Neil
