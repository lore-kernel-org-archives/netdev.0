From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: genphy_read_status() vs. 1000bT Pause capability
Date: Tue, 28 Mar 2017 11:49:50 +1100
Message-ID: <1490662190.3177.91.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59084 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753677AbdC1AuO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 20:50:14 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v2S0noi8016162
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 19:49:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi !

I noticed that flow control isn't being enabled on a system I'm
working on by default. I've tracked it down to two things:

 - The realtec.c PHY driver doesn't have Pause or Asym_Pause in
its exposed capabilities. This is in part because PHY_GBIT_FEATURES
does not include SUPPORTED_Pause and SUPPORTED_Asym_Pause. Is there
a specific reason for that ?

 - After I've hacked the above, I get in genphy_read_status():

lpa=c1e1 lpagb=3800 adv=de1 common_adv=1e1 common_adv_gb=800

So we have negociated 1000bT full duplex. LPA_PAUSE's aren't set
but I was under the impression that in Gigabit mode, LPA bit 0x80
which *is* set, meant ADVERTISE_1000XPAUSE which is the pause
capability isn't it ? Or am I confusing with something else ?
This seems to be how mii_adv_to_ethtool_adv_x() decodes them
but that function is not called by genphy_read_status()...

Now it's been a while since I hacked network drivers and back then
everybody did their own salad with gigabit PHYs so it's very possible
that I missed something here.

Should we update genphy_read_status() to grab the pause details
from mii_adv_to_ethtool_adv_x() when in 1000bT mode ?

Thanks !

Cheers,
Ben.
