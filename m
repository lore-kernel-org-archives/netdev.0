From: Teresa Remmet <t.remmet@phytec.de>
Subject: net: phy: SMSC LAN8710/LAN8720 high load
Date: Mon, 11 Jan 2016 08:41:55 +0100
Message-ID: <1452498115.7467.23.camel@lws-tremmet.phytec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Igor Plyatov <plyatov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

we have noticed load issues on our AM335x boards with a LAN8710 phy while 
cpu is idling using 4.4-rc8.

CPU:   0% usr   0% sys   0% nic  99% idle   0% io   0% irq   0% sirq
Load average: 1.21 1.16 1.00 1/84 372

We could track this down to the ethernet phy. And bisect the issue to the
following patch:

commit 776829de90c5972895db398993ddfa9417ff8b01
Author: Igor Plyatov <plyatov@gmail.com>
Date:   Fri Aug 14 20:11:02 2015 +0300

    net: phy: workaround for buggy cable detection by LAN8700 after cable plugging
    * Due to HW bug, LAN8700 sometimes does not detect presence of energy in the
      Ethernet cable in Energy Detect Power-Down mode (e.g while EDPWRDOWN bit is
      set, the ENERGYON bit does not asserted sometimes). This is a common bug of
      LAN87xx family of PHY chips.
    * The lan87xx_read_status() was improved to acquire ENERGYON bit. Its previous
      algorythm still not reliable on 100 % and sometimes skip cable plugging.
    
    Signed-off-by: Igor Plyatov <plyatov@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Reverting the commit helped to make the load drop down to:

09:21:01 up 32 min,  load average: 0.19, 0.17, 0.14                   

In both cases no ethernet cable as been connected.

We also struggle with the buggy cable detection issue, but this increase of load
doesn't seem acceptable.

Can someone else with a LAN87xx also reproduce this?

Regards
Teresa
