From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH v2 0/7] Introduce of_get_child_by_name.
Date: Fri, 14 Sep 2012 09:17:12 +0100
Message-ID: <1347610632-20061-1-git-send-email-srinivas.kandagatla@st.com>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, jassi.brar@samsung.com,
	afleming@freescale.com, srinivas.kandagatla@st.com,
	grant.likely@secretlab.ca
To: davem@davemloft.net, robherring2@gmail.com, bergner@us.ibm.com,
	devicetree-discuss@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:55184 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755628Ab2INIVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 04:21:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch series introduces of_get_child_by_name function to get a 
child node by its name in a given parent node and also removes code 
duplication in some of the existing driver code by using of_get_child_by_name.

Normally if a driver want to get a child node it would iterate all the nodes
of parent and compare its name and then get it.
This use case is becoming common as device trees are used more, so moving this 
functionality to a libary function makes sense.

Having of_get_child_by_name libary function would avoid code duplication,
errors and is more convenient.

Changes from v1:
	-rename of_get_child to of_get_child_by_name.
	-remove read lock in of_get_child_by_name.
	-make use of of_get_child_by_name in the existing kernel code.

Srinivas Kandagatla (7):
  dt: introduce of_get_child_by_name to get child node by name.
  dt/powerpc: Use of_get_child_by_name to get a named child.
  dt/powerpc/powernv: Use of_get_child_by_name to get a named child.
  dt/powerpc/sysdev: Use of_get_child_by_name to get a named child.
  dt/net/fsl_pq_mdio: Use of_get_child_by_name to get a named child.
  dt/s3c64xx/spi: Use of_get_child_by_name to get a named child.
  dt/tty/opal: Use of_get_child_by_name to get a named child.

 arch/powerpc/kernel/prom.c                   |    5 +----
 arch/powerpc/platforms/powernv/opal.c        |    6 ++----
 arch/powerpc/sysdev/qe_lib/qe.c              |    5 +----
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |    5 +----
 drivers/of/base.c                            |   25 +++++++++++++++++++++++++
 drivers/spi/spi-s3c64xx.c                    |    4 +---
 drivers/tty/hvc/hvc_opal.c                   |    9 ++-------
 include/linux/of.h                           |    2 ++
 8 files changed, 35 insertions(+), 26 deletions(-)
