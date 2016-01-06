From: David Wragg <david@weave.works>
Subject: [PATCH net 0/2] vxlan: Set a large MTU on ovs-created vxlan devices
Date: Wed,  6 Jan 2016 13:33:04 +0000
Message-ID: <1452087186-12926-1-git-send-email-david@weave.works>
Cc: David Wragg <david@weave.works>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34999 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbcAFNdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 08:33:16 -0500
Received: by mail-wm0-f45.google.com with SMTP id f206so59613133wmf.0
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 05:33:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to 4.3, openvswitch vxlan vports could transmit vxlan packets of
any size, constrained only by the ability to transmit the resulting
UDP packets.  4.3 introduced vxlan netdevs corresponding to vxlan
vports.  These netdevs have an MTU, which limits the size of a packet
that can be successfully vxlan-encapsulated.  The default value for
this MTU is 1500, which is awkwardly small, and leads to a conspicuous
change in behaviour for userspace.

These two patches set the MTU on openvswitch-crated vxlan devices to
be 65465 (the maximum IP packet size minus the vxlan-on-IPv6
overhead), effectively restoring the behaviour prior to 4.3.  In order
to accomplish this, the first patch removes the MTU constraint of 1500
for vxlan netdevs without an underlying device.

David Wragg (2):
  vxlan: Relax the MTU constraint on vxlan devices
  vxlan: Set a large MTU on ovs-created vxlan devices

 drivers/net/vxlan.c           | 38 +++++++++++++++++++++++++-------------
 net/openvswitch/vport-vxlan.c |  2 ++
 2 files changed, 27 insertions(+), 13 deletions(-)

-- 
2.5.0
