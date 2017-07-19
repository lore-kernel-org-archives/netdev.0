From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH 0/4] can: Add new binding to limit bit rate used
Date: Wed, 19 Jul 2017 18:36:50 -0500
Message-ID: <20170719233654.25908-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>,
        <dev.kurt@vandijck-laurijssen.be>, <andrew@lunn.ch>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new generic binding that CAN drivers can use to specify the max
arbitration and data bit rate supported by a transceiver. This is
useful since in some instances the maximum speeds may be limited by
the transceiver used. However, transceivers may not provide a means
to determine this limitation at runtime. Therefore, create a new binding
that mimics "fixed-link" that allows a user to hardcode the max speeds
that can be used.

Also add support for this new binding in the MCAN driver.

Note this is an optional subnode so even if a driver adds support for
parsing fixed-transceiver the user does not have to define it in their
device tree.

Franklin S Cooper Jr (4):
  can: dev: Add support for limiting configured bitrate
  can: fixed-transceiver: Add documentation for CAN fixed transceiver
    bindings
  can: m_can: Update documentation to mention new fixed transceiver
    binding
  can: m_can: Add call to of_transceiver_is_fixed

 .../bindings/net/can/fixed-transceiver.txt         | 31 ++++++++++++++
 .../devicetree/bindings/net/can/m_can.txt          | 10 +++++
 drivers/net/can/dev.c                              | 48 ++++++++++++++++++++++
 drivers/net/can/m_can/m_can.c                      |  2 +
 include/linux/can/dev.h                            |  5 +++
 5 files changed, 96 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/can/fixed-transceiver.txt

-- 
2.10.0

