From: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v4 0/4] can: Support transceiver based bit rate limit
Date: Wed, 9 Aug 2017 19:59:12 -0500
Message-ID: <20170810005916.27163-1-fcooper@ti.com>
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

Add a new generic binding that CAN drivers can be used to specify the max
bit rate supported by a transceiver. This is useful since in some instances
since the maximum speeds may be limited by the transceiver used. However,
transceivers may not provide a means to determine this limitation at
runtime. Therefore, create a new binding that mimics "fixed-link" that
allows a user to hardcode the max speeds that can be used.

Also add support for this new binding in the MCAN driver.

Note this is an optional subnode so even if a driver adds support for
parsing can-transceiver the user does not have to define it in their
device tree.

Version 4 changes:
Switch from fixed-transceiver to can-transceiver
Drop unit address that snuck back in again.
Indicate that can-transceiver is a subnode and not a property in
documentation

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
  dt-bindings: can: can-transceiver: Document new binding
  dt-bindings: can: m_can: Document new can transceiver binding
  can: m_can: Add call to of_can_transceiver

 .../bindings/net/can/can-transceiver.txt           | 24 +++++++++++
 .../devicetree/bindings/net/can/m_can.txt          |  9 ++++
 drivers/net/can/dev.c                              | 50 ++++++++++++++++++++++
 drivers/net/can/m_can/m_can.c                      |  2 +
 include/linux/can/dev.h                            |  5 +++
 5 files changed, 90 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/can/can-transceiver.txt

-- 
2.9.4.dirty

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
