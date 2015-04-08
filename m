From: Mason <slash.tmp@free.fr>
Subject: Atheros 8035 PHY only works when at803x_config_init() is commented out
Date: Wed, 08 Apr 2015 18:28:13 +0200
Message-ID: <5525571D.7060909@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:27167 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754463AbbDHQ2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 12:28:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone,

I have a weird problem, that I've only started investigating, and I'd be
grateful if anyone can help me along.

I have an ARM-based SoC that provides (AFAIU) an Atheros 8035 PHY.

If I enable the driver in my kernel (CONFIG_AT803X_PHY) then something
goes wrong, and the system cannot load the nfsroot. Bizarrely, DHCP
seems to work (so there is limited connectivity) but then the NFS
server just times out.

However, if I just comment this line:
	//.config_init = at803x_config_init,
in at803x_driver[0]
then everything seems to work. (At least, the system sets the PHY
to Gbit, and manages to download the nfsroot.)

If I'm reading the code right (big "if"), when config_init is NULL,
then phy_init_hw() turns into a NOP?

So either at803x_config_init() or something called from phy_init_hw()
seems to be hosing this system's networking?

Sprinkling printk over phy_init_hw shows no errors (no premature exit)
and phydev->drv->config_init(phydev) returns 0.

Maybe I didn't set something up correctly, and phy_write() is scribbling
over the wrong register?

Does anyone see something I missed?

Regards.
