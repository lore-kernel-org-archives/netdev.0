From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH v3 0/4] can: Support transceiver based bit rate limit
Date: Wed, 2 Aug 2017 19:51:46 -0500
Message-ID: <20170803005150.9286-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>,
        <dev.kurt@vandijck-laurijssen.be>, <andrew@lunn.ch>,
        <sergei.shtylyov@cogentembedded.com>, <socketcan@hartkopp.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new generic binding that CAN drivers can be used to specify the max
bit rate supported by a transceiver. This is useful since in some instances
since the maximum speeds may be limited by the transceiver used. However,
transceivers may not provide a means to determine this limitation at
runtime. Therefore, create a new binding that mimics "fixed-link" that
allows a user to hardcode the max speeds that can be used.

Also add support for this new binding in the MCAN driver.

Note this is an optional subnode so even if a driver adds support for
parsing fixed-transceiver the user does not have to define it in their
device tree.

Version 3 changes:
Switch from having two "max bitrates" to one universal bitrate.

Version 2 changes:
Rename function
Define proper variable default
Drop unit address
Move check to changelink function
Reword commit message
Reword documentation

Franklin S Cooper Jr (4):
  can: dev: Add support for limiting configured bitrate
  dt-bindings: can: fixed-transceiver: Add new CAN fixed transceiver
    bindings
  dt-bindings: can: m_can: Include reference to new fixed transceiver
    binding
  can: m_can: Add call to of_can_transceiver_fixed

 .../bindings/net/can/fixed-transceiver.txt         | 24 +++++++++++
 .../devicetree/bindings/net/can/m_can.txt          |  9 ++++
 drivers/net/can/dev.c                              | 50 ++++++++++++++++++++++
 drivers/net/can/m_can/m_can.c                      |  2 +
 include/linux/can/dev.h                            |  5 +++
 5 files changed, 90 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/can/fixed-transceiver.txt

-- 
2.9.4.dirty
