From: anuradhak@cumulusnetworks.com
Subject: [PATCH net-next v2 0/3] net: introduce IFF_PROTO_DOWN flag.
Date: Sat, 21 Mar 2015 21:06:55 -0700
Message-ID: <1426997218-27313-1-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34288 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbbCVEHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 00:07:06 -0400
Received: by pdbni2 with SMTP id ni2so150182732pdb.1
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2015 21:07:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

User space daemons can detect errors in the network that need to be
notified to the netdev drivers. Drivers can react to this error state
by stopping processing and turning off the carrier.

One such use case is the multi-chassis LAG application. When a split
brain situation is detected between the MLAG peers the secondary MLAG
switch typically stops processing on its MLAG enabled devices. Doing
that helps close traffic black-hole/loop windows quickly.

This series includes a patch for virtio net driver showing a sample
driver handling of the proto down flag

IFF_PROTO_DOWN doesn't interfere with the device admin state. It is
similar to the dormant mode/state that allows applications control of
the operational state as defined by RFC2863.

v1 to v2:
    Based on Dave's suggestion I have moved out aggregating of error
    bits across applications to an user space framework. This patch now
    simply notifies an aggregated error bit to drivers enabling them
    to handle the error gracefully.

Anuradha Karuppiah (2):
  net core: Add IFF_PROTO_DOWN support.
  virtio net: Handle proto_down state by setting the carrier off.

 drivers/net/virtio_net.c |   78 +++++++++++++++++++++++++++++++++++++++++++---
 include/uapi/linux/if.h  |    4 +++
 net/core/dev.c           |    2 +-
 3 files changed, 79 insertions(+), 5 deletions(-)

-- 
1.7.10.4
