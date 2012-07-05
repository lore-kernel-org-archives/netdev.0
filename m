From: Andy Green <andy@warmcat.com>
Subject: [PATCH 4 0/4] Add ability to set defaultless network device MAC
 addresses to deterministic computed locally administered values
Date: Thu, 05 Jul 2012 10:44:33 +0800
Message-ID: <20120705024259.26317.16000.stgit@build.warmcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: s-jan@ti.com, arnd@arndb.de, patches@linaro.org, tony@atomide.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rostedt@goodmis.org, linux-arm-kernel@lists.infradead.org
To: linux-omap@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following series adds some code to generate legal, locally administered
MAC addresses from OMAP4 CPU Die ID fuse data, and then adds a helper at
net/ethernet taking care of accepting device path / MAC mapping registrations
and running a notifier to enforce the requested MAC when the matching network
device turns up.

On PandaBoard / ES, two devices have no board-level MAC either assigned by
the manufacturer or stored on the board, the last patch in the series adds
these device paths and gets them set when the network device is registered.

Lastly for convenient testing, there's a little patch on omap2plus_defconfig
that will get Ethernet and WLAN up on Pandaboard.

The patches are against today's linux-omap.

Thanks to Tony Lindgren and Arnd Bergmann for comments leading to the
helper in net/ethernet.

---

Andy Green (4):
      OMAP: add cpu id register to MAC address helper
      NET ethernet introduce mac_platform helper
      OMAP4 PANDA register ethernet and wlan for automatic mac allocation
      config test config extending omap2plus with wl12xx etc


 arch/arm/configs/omap2plus_defconfig   |   35 +++----
 arch/arm/mach-omap2/Kconfig            |    1 
 arch/arm/mach-omap2/board-omap4panda.c |   30 ++++++
 arch/arm/mach-omap2/id.c               |   39 ++++++++
 arch/arm/mach-omap2/include/mach/id.h  |    1 
 include/net/mac-platform.h             |   39 ++++++++
 net/Kconfig                            |    5 +
 net/ethernet/Makefile                  |    3 +
 net/ethernet/mac-platform.c            |  151 ++++++++++++++++++++++++++++++++
 9 files changed, 282 insertions(+), 22 deletions(-)
 create mode 100644 include/net/mac-platform.h
 create mode 100644 net/ethernet/mac-platform.c

