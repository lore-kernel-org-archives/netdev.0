From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [PATCH] core: linkwatch should use jiffies64
Date: Mon, 8 May 2006 20:28:56 +0200
Message-ID: <200605082028.57328.stefan@loplof.de>
References: <200605071213.56877.stefan@loplof.de> <20060507.230727.67882043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nattrymon.rzone.de ([81.169.145.178]:20709 "EHLO
	nattrymon.rzone.de") by vger.kernel.org with ESMTP id S1751274AbWEHS2R
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 14:28:17 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060507.230727.67882043.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag 08 Mai 2006 08:07 schrieb David S. Miller:

> What is so special about what linkwatch is doing such
> that it needs this kind of treatment and other similar
> pieces or code do not?
>
> We have all sorts of interfaces such as time_after() et el.
> in order to deal with wrapping issues.

time_after() and friends can handle jiffies wrapping, however they require the 
difference between compared times to be less than 0x80000000 jiffies (about 
24 days on HZ=1000) to work reliably on 32bit architectures. So if the 
network is stable for 24 days, events generated within days 25-49 will suffer 
a *huge* false delay.

> And furthermore 
> using 64-bit jiffies here might not be appropriate because
> they are not guarenteed to be accessed atomically,

get_jiffies_64() handles this transparently.

Stefan
