From: Igor Plyatov <plyatov@gmail.com>
Subject: Buggy cable detection on i.MX51, fec driver and LAN8700 PHY
Date: Mon, 27 Jul 2015 17:50:36 +0300
Message-ID: <55B6453C.10500@gmail.com>
Reply-To: plyatov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Joe Perches <joe@perches.com>,
	Luwei Zhou <b45643@freescale.com>, b38611@freescale.com,
	Richard Cochran <richardcochran@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?VXdlIEtsZWluZS1Lw7ZuaQ==?= =?UTF-8?B?Zw==?=
	<u.kleine-koenig@pengutronix.de>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	=?UTF-8?B?TG90aGFyIFdhw59tYW5u?= <LW@KARO-electronics.de>,
	Frank Li <Frank.Li@freescale.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear all,

very often we observe issue with Ethernet cable detection during cable 
unplugging and plugging.

We use Voipac i.MX51 SOMs (System On Modules). They are based on 
Freescale i.MX51 CPU with LAN7800 PHY in MII mode. The schematic of PHY 
connection is very similar to the Freescale i.MX51 Babbage board.

The Ethernet interface eth0 is configured statically for simplicity, but 
same issue exists with DHCP configuration.

I did a lot of tests to determine stability of Ethernet cable detection 
by the "fec" Ethernet driver.

In normal operation, if I unplug the Ethernet cable, then "fec" driver 
prints "fec 83fec000.ethernet eth0: Link is Down" and green LED 
(Ethernet medium detected) is OFF.
If I plug cable back, then "fec" driver print "fec 83fec000.ethernet 
eth0: Link is Up - 100Mbps/Full - flow control off" and green LED is ON.

But sometimes, after cable plugging, "fec" driver does not print 
anything on the console and green LED does not show detection of 
Ethernet cable. Frequency of issue appearing is a random value. 
Sometimes issue appears after second cable unplugging/plugging, but 
sometimes - after 10-20 unplugging/plugging.

The issue was tested and exists on kernels from linux-3.8.5 till current 
linux-4.2-rc4-cbfe8fa6cd672011c755c3cd85c9ffd4e2d10a6f.

Same tests was made with different versions of the Barebox bootloader 
and cable detection works flawless.

Please, help to resolve issue with Linux drivers.

Best wishes.
--
Igor Plyatov
