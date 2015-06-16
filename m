From: arno@natisbad.org (Arnaud Ebalard)
Subject: [BUG,BISECTED] mvneta: second interface no more usable on mirabox
Date: Tue, 16 Jun 2015 23:44:00 +0200
Message-ID: <87a8vz72hr.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Stas Sergeev <stsp@list.ru>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 36.223.133.77.rev.sfr.net ([77.133.223.36]:58161 "EHLO
	smtp.natisbad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbbFPVuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 17:50:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mirabox, the second ethernet interface is no more usable on 4.1-rc*
series (no packets coming out of the interface, when using dhclient for
instance). It works as expected on 4.0.

Bisecting the issue, I ended up on 898b2970e2c9 ("mvneta: implement
SGMII-based in-band link state signaling"). Reverting that commit gives 
me back the second interface.

Then, I also tested on a NETGEAR ReadyNAS 104, which is also powered by
the same SoC (Armada 370) and also has two (mvneta-supported) ethernet
interfaces. With an unmodified 4.1-rc8, only one of the two interfaces
is available. Reverting 898b2970e2c9 makes both usable again.

FWIW, mirabox and RN104 ethernet interfaces use RGMII.

Cheers,

a+
