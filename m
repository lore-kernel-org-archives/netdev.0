From: Marco Chiappero <marco.chiappero@intel.com>
Subject: [PATCH net-next 0/9] support unique MAC addresses for slave devices
Date: Thu, 27 Apr 2017 15:51:33 +0100
Message-ID: <20170427145142.15830-1-marco.chiappero@intel.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Sainath Grandhi <sainath.grandhi@intel.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Marco Chiappero <marco.chiappero@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:58459 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753906AbdD0Owf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 10:52:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently every slave device gets assigned the same MAC address, by
having it copied from the master interface. Since some code paths
depend on this identity, changing the MAC address on slave interfaces
is not supported. However identical MAC addresses can pose problems to
management and orchestration software that correctly expect network
interfaces on the same segment to have unique addresses.

Patches 1-8 include style fixes and refactoring (patch 9 depends upon)
that improve the overal quality and make the intruduction of the
feature straightforward.

Patch 9 enables slave devices to own unique MAC addresses and change
such addresses live, fixing lack of support and a related bug, as
MAC address changes on master were not propagated to slave devices.
In order to preserve the main peculiarity of this driver, that is
exposing only a single MAC address for outbound traffic, frames
egressing from master are now effectively masquerated when working in
L2 mode.

Marco Chiappero (9):
  ipvlan: fix coding style for the ipvlan tree
  ipvlan: refactor ipvlan_process_multicast for readability
  ipvlan: replace ipvlan_rcv_frame
  ipvlan: rework the IP lookup function
  ipvlan: improve and uniform naming
  ipvlan: reposition three functions
  ipvlan: relocate ipvlan_skb_crossing_ns calls
  ipvlan: improve compiler hints
  ipvlan: introduce individual MAC addresses

 drivers/net/ipvlan/ipvlan.h      |   2 +-
 drivers/net/ipvlan/ipvlan_core.c | 592 ++++++++++++++++++++-------------------
 drivers/net/ipvlan/ipvlan_main.c |  49 ++--
 drivers/net/ipvlan/ipvtap.c      |   1 +
 4 files changed, 333 insertions(+), 311 deletions(-)

-- 
2.9.3

--------------------------------------------------------------
Intel Research and Development Ireland Limited
Registered in Ireland
Registered Office: Collinstown Industrial Park, Leixlip, County Kildare
Registered Number: 308263


This e-mail and any attachments may contain confidential material for the sole
use of the intended recipient(s). Any review or distribution by others is
strictly prohibited. If you are not the intended recipient, please contact the
sender and delete all copies.
