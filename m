From: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v2 0/4] can: Add new binding to limit bit rate used
Date: Mon, 24 Jul 2017 18:05:17 -0500
Message-ID: <20170724230521.1436-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        <dev.kurt-yI9piX4KPfawT/RRk36CISFp6vIno51x@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>,
        <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>, <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

Version 2 changes:
Rename function
Define proper variable default
Drop unit address
Move check to changelink function
Reword commit message
Reword documentation

Franklin S Cooper Jr (4):
  can: dev: Add support for limiting configured bitrate
  can: fixed-transceiver: Add documentation for CAN fixed transceiver
    bindings
  can: m_can: Update documentation to mention new fixed transceiver
    binding
  can: m_can: Add call to of_can_transceiver_fixed

 .../bindings/net/can/fixed-transceiver.txt         | 42 +++++++++++++++
 .../devicetree/bindings/net/can/m_can.txt          | 10 ++++
 drivers/net/can/dev.c                              | 59 ++++++++++++++++++++++
 drivers/net/can/m_can/m_can.c                      |  2 +
 include/linux/can/dev.h                            |  5 ++
 5 files changed, 118 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/can/fixed-transceiver.txt

-- 
2.10.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
