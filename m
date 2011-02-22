From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 0/4] simple generic timer infrastructure and stmmac example
Date: Tue, 22 Feb 2011 11:17:40 +0100
Message-ID: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Stuart MENEFY <stuart.menefy@st.com>,
	Peppe CAVALLARO <peppe.cavallaro@st.com>
To: "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many devices targeted at the embedded market provide a number of
generic timers which are capable of generating interrupts at a
requested rate. These can then be used in the implementation of drivers
for other peripherals which require a timer interrupt, without having
to provide an additional timer as part of that peripheral.

A code provides a simple abstraction layer which allows a timer to be
registered, and for a driver to request a timer.
Currently this doesn't provide any of the additional information, such
as precision or position in clock framework which might be required
for a fully featured driver.

This patches also updates the stmmac Network device driver to use
the generic timer infrastructure The timer is used for mitigating
the number of the interrupts. This helps many people to save the
CPU on STM platforms with MAC10/100 and GMAC device without an
embedded timer.

Welcome comments and review.

Giuseppe Cavallaro (3):
  sh_timer: add the support to use the generic timer
  stmmac: switch to use the new generic timer interface
  stmmac: rework and improvement the stmmac timer

Stuart Menefy (1):
  clksource: Generic timer infrastructure

 drivers/clocksource/Makefile       |    1 +
 drivers/clocksource/generictimer.c |   60 +++++++++++++++++++++
 drivers/clocksource/sh_tmu.c       |   72 +++++++++++++++++++++++++
 drivers/net/stmmac/Kconfig         |   19 ++++---
 drivers/net/stmmac/Makefile        |    2 +-
 drivers/net/stmmac/common.h        |    6 ++
 drivers/net/stmmac/stmmac.h        |    5 +-
 drivers/net/stmmac/stmmac_main.c   |   66 ++++++++++++-----------
 drivers/net/stmmac/stmmac_timer.c  |  103 +++++++++++++++++++++---------------
 drivers/net/stmmac/stmmac_timer.h  |   12 ++---
 include/linux/generictimer.h       |   41 ++++++++++++++
 11 files changed, 295 insertions(+), 92 deletions(-)
 create mode 100644 drivers/clocksource/generictimer.c
 create mode 100644 include/linux/generictimer.h

-- 
1.7.4
