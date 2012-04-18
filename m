From: David Daney <ddaney.cavm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v5 0/3] netdev/of/phy: MDIO bus multiplexer support.
Date: Wed, 18 Apr 2012 16:20:51 -0700
Message-ID: <1334791254-15987-1-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, afleming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
 Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

This code has been working well for about six months on a couple of
different configurations (boards), so I thought it would be a good
time to send it out again, and I hope get it on the path towards
merging.

v5: Correct Kconfig depends in 3/3 as noticed by David Miller.

v4: Correct some comment text and rename a couple of variables to
    better reflect their purpose.

v3: Update binding to use "mdio-mux-gpio" compatible property.
    Cleanups suggested by Grant Likely.  Now uses the driver probe
    deferral mechanism if GPIOs or parent bus not available.

v2: Update bindings to use "reg" and "mdio-parent-bus" instead of
    "cell-index" and "parent-bus"

v1:

We have several different boards with a multiplexer in the MDIO bus.
There is an MDIO bus controller connected to a switching device with
several child MDIO busses.

Everything is wired up using device tree bindings.

 1/3 - New of_mdio_find_bus() function used to help configuring the
       driver topology.

 2/3 - MDIO bus multiplexer framework.

 3/3 - A driver for a GPIO controlled multiplexer.

David Daney (3):
  netdev/of/phy: New function: of_mdio_find_bus().
  netdev/of/phy: Add MDIO bus multiplexer support.
  netdev/of/phy: Add MDIO bus multiplexer driven by GPIO lines.

 .../devicetree/bindings/net/mdio-mux-gpio.txt      |  127 +++++++++++++
 Documentation/devicetree/bindings/net/mdio-mux.txt |  136 ++++++++++++++
 drivers/net/phy/Kconfig                            |   18 ++
 drivers/net/phy/Makefile                           |    2 +
 drivers/net/phy/mdio-mux-gpio.c                    |  142 +++++++++++++++
 drivers/net/phy/mdio-mux.c                         |  192 ++++++++++++++++++++
 drivers/net/phy/mdio_bus.c                         |   32 ++++
 drivers/of/of_mdio.c                               |    2 +
 include/linux/mdio-mux.h                           |   21 ++
 include/linux/of_mdio.h                            |    2 +
 10 files changed, 674 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/mdio-mux-gpio.txt
 create mode 100644 Documentation/devicetree/bindings/net/mdio-mux.txt
 create mode 100644 drivers/net/phy/mdio-mux-gpio.c
 create mode 100644 drivers/net/phy/mdio-mux.c
 create mode 100644 include/linux/mdio-mux.h

-- 
1.7.2.3
