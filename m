From: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
Subject: [PATCH 0/3] MOST network protocol
Date: Mon, 10 Jun 2013 14:52:14 +0200
Message-ID: <cover.1370856733.git.asnaghi@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Alessandro Rubini <rubini@gnudd.com>,
	Federico Vaga <federico.vaga@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set includes known-working code, developed by Wind River
and Intel, published at http://sourceforge.net/projects/sta2x11/ .

We fixed a number of things in the code, porting to the current
linux-next and upstream sta2x11 code, factorizing replicated code,
making stuff more readable and fixing buglets. (We is Federico Vaga,
Alessandro Rubini, Giancarlo Asnaghi).

Patch 1 is the core, patch 2 is an interface driver and patch 3 is a
pci fixup in the chipset that hosts the logic block for the interface.

Unfortunately, the code implements network-specific system calls but
doesn't fit in the kernel network subsystem. Instead of using skbuffs
and network interfaces, it sets up a direct connection between the
system calls and custom-defined operations for the hardware driver.

We are aware patch 1/3 and 2/3 cannot be merged without serious
refactoring, and for this reason we are not adding signed-off-by
markers.

Still, we think the current code may be useful to other people
nonetheless: the MOST protocol is not very common, but it is not an
exotic single-vendor thing, either.

We plan to work on resubmitting this in the upcoming months, adapting
to the proper conventions for a network protocol.

Giancarlo Asnaghi (3):
  net: add support for MOST protocol
  drivers/net/most: add MediaLB driver for sta2x11
  arch/x86/pci/sta2x11-fixup.c: reset and enable STA2X11 MediaLB clock

 arch/x86/pci/sta2x11-fixup.c  |   17 +
 drivers/net/Makefile          |    1 +
 drivers/net/most/Kconfig      |   10 +
 drivers/net/most/Makefile     |    6 +
 drivers/net/most/sta2x11mlb.c | 1181 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/most/sta2x11mlb.h |  275 ++++++++++
 include/linux/socket.h        |    4 +-
 include/net/most/most.h       |  238 +++++++++
 net/Kconfig                   |    1 +
 net/Makefile                  |    1 +
 net/core/sock.c               |    9 +-
 net/most/Kconfig              |   15 +
 net/most/Makefile             |    6 +
 net/most/af_most.c            |  967 +++++++++++++++++++++++++++++++++
 14 files changed, 2727 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/most/Kconfig
 create mode 100644 drivers/net/most/Makefile
 create mode 100644 drivers/net/most/sta2x11mlb.c
 create mode 100644 drivers/net/most/sta2x11mlb.h
 create mode 100644 include/net/most/most.h
 create mode 100644 net/most/Kconfig
 create mode 100644 net/most/Makefile
 create mode 100644 net/most/af_most.c

-- 
1.7.7.2
