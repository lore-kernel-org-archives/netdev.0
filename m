From: Damien Riegel <damien.riegel@savoirfairelinux.com>
Subject: [PATCH v2 0/3] can: sja1000: support for technologic version
Date: Thu, 24 Dec 2015 12:42:50 -0500
Message-ID: <1450978973-30417-1-git-send-email-damien.riegel@savoirfairelinux.com>
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	kernel@savoirfairelinux.com,
	Damien Riegel <damien.riegel@savoirfairelinux.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset introduces support for the technologic version of the
SJA1000. Access to IP's registers are proxied through a window,
requiring two bus accesses to read or write a register. These accesses
must be protected by a spinlock to prevent race conditions. Currently,
there is no easy way to allocate and initialize this spinlock.

SJA1000 already provides a way to allocate private data, but
sja1000_platform.c makes no use of it.

Patch 1 adds the capability to allocate and initialize private data on a
per-compatible basis in sja1000_platform.c.

Patch 2 updates device tree documentation to add the technologic
version.

Patch 3 updates the driver to implement the technologic version

Changes in v2:
 - added a patch to allocate and initialize private data
 - changed device tree documentation
 - added a spinlock to protect bus accesses
 - changed sp_{read,write}_reg16 to io{read,write}16

Damien Riegel (3):
  can: sja1000: of: add per-compatible init hook
  can: sja1000: add documentation for Technologic Systems version
  can: sja1000: of: add compatibility with Technologic Systems version

 .../devicetree/bindings/net/can/sja1000.txt        |  3 +-
 drivers/net/can/sja1000/sja1000_platform.c         | 86 +++++++++++++++++++++-
 2 files changed, 86 insertions(+), 3 deletions(-)

-- 
2.5.0

