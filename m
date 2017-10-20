From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v3 net-next 0/2] net: dsa: lan9303: Add fdb/mdb methods
Date: Fri, 20 Oct 2017 12:19:08 +0200
Message-ID: <20171020101910.2245-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:55822 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752087AbdJTKTu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Oct 2017 06:19:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series add support for accessing and managing the lan9303 ALR 
(Address Logic Resolution). 

The first patch add low level functions for accessing the ALR, along
with port_fast_age and port_fdb_dump methods.

The second patch add functions for managing ALR entires, along with
remaining fdb/mdb methods. 

Note that to complete STP support, a special ALR entry with the STP eth
address must be added too. This must be addressed later.

Comments welcome!


Changes v2 -> v3:
 - Whitespace polishing. Removed some "section" comments.
 - Prefixed ALR constants with LAN9303_ for consistency.
 - Patch 2: lan9303_port_fast_age() wrap the "port" into a struct for passing
   as context to alr_loop_cb_del_port_learned. Safer in event of type change.
 - Patch 2: Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
  
Changes v1 -> v2:
 - Patch 2: Removed question comment


Egil Hjelmeland (2):
  net: dsa: lan9303: Add port_fast_age and port_fdb_dump methods
  net: dsa: lan9303: Add fdb/mdb manipulation

 drivers/net/dsa/lan9303-core.c | 333 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/lan9303.h      |  11 ++
 2 files changed, 344 insertions(+)

-- 
2.11.0
