From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 0/2] Indirect phy access for mv88e6171
Date: Sun, 15 Feb 2015 10:32:40 -0800
Message-ID: <54E0E648.8080206@roeck-us.net>
References: <1423937871-9180-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:35865 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754948AbbBOSco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 13:32:44 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YN3zn-003V7c-5S
	for netdev@vger.kernel.org; Sun, 15 Feb 2015 18:32:43 +0000
In-Reply-To: <1423937871-9180-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2015 10:17 AM, Andrew Lunn wrote:
> These two patches allow the mv88e6171 driver to access the port phys
> using indirect addressing. Depending on pin strapping, the switch
> either uses a single address on the host MDIO bus, requiring the port
> phys are accessed indirectly, or the switch uses a number of addresses
> on the host bus and the phys can be directly accessed.
>
> The 370RD, the first supported platform to use the 6171 uses multiple
> addresses, so this indirect mode was not required. However the
> WRT1900AC has the switch configured to use a single address, and so
> indirect access is needed.
>
> The mv88e6352 already has all the needed code. Refactor it into the
> shared mv88e6xxx and then use it in the mv88e6171 driver.
>
> Tested on the 370RD and WRT1900AC.
>
> It would be good if Guenter Roeck could test on his platform to ensure
> i've not broken anything for the mv88e6352.
>

I'll try. My primary problem right now is that I run Lennert Buytenhek's
patch set to support bridging offload (aka hardware bridging) on top of
the upstream dsa code, and the upstream code now supports a competing /
alternate means  to support bridging/switching offload (NET_SWITCHDEV)
which doesn't work with dsa (at least not yet). So I'll have to figure
out if / how I can run your patches with my code base, or how I can add
add support for NET_SWITCHDEV into dsa.

Do you know if there are any efforts going on in that direction ?

Thanks,
Guenter
