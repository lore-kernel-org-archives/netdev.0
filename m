From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH netdev-2.6] jme: JMicron Gigabit Ethernet Driver
Date: Sat, 23 Aug 2008 02:41:59 -0400
Message-ID: <48AFB137.9020506@pobox.com>
References: <48AFA8A8.6070604@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ethan <ethanhsiao@jmicron.com>, akeemting <akeem@jmicron.com>,
	netdev@vger.kernel.org
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46248 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751286AbYHWGmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2008 02:42:10 -0400
In-Reply-To: <48AFA8A8.6070604@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guo-Fu Tseng wrote:
> Hi, Jeff:
> 
> Here is the full patch of JMicron Gigabit Ethernet driver.
> Supporting JMC250, and JMC260.
> 
> I'm new in this submitting system, I've tried hard not to done silly 
> errors.
> Comments, and corrections are welcome from anyone. Thank you for 
> reviewing it.
> 
> The patch is also available at:
> http://cooldavid.org/download/jme.netdev-2.6.20080823.patch
> 
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Very nice and clean and feature-complete!  Comments:

* the definition of jwrite32() and jread32():  writel() and readl() are 
defined in terms of the little-endian PCI bus, and therefore 
automatically handle byteswapping (or not) as defined by the platform API.

You should be able to just remove those le32_to_cpu() and the reverse, 
to obtain proper behavior.

* The atomic values rx_cleaning and tx_cleaning look problematic and 
potentially racy, though I admit not having completely evaluated its usage.

* we prefer not to add custom ioctls, but rather add functionality to 
ethtool.  in particular, JMESPIIOCTL does not appear to have any 
security checks, and is a potential security hole that permits an 
unpriveleged user direct access to hardware

