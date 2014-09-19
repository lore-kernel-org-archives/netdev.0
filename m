From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 0/2] tg3:  Fix handling of non-acceleration vlans
Date: Fri, 19 Sep 2014 18:23:07 -0400
Message-ID: <1411165389-21276-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:37010 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932195AbaISWXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 18:23:20 -0400
Received: by mail-qg0-f42.google.com with SMTP id i50so599854qgf.1
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 15:23:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TG3 can't cope with checksum and TSO offloads when vlan headers were
not accelerated.  This can be demonstrated with 802.1ad vlans or
by configuring a vlan on top of a bridge and turning off vlan acceleration
on the bridge device.

Instead of disabling all vlan acceleration, this series works around
the issue by having tg3 driver call software segmentation and checksum
generation.

v2: - moved the call to software segment soonner
    - Preserve the checksum flags for TSO/LSO case and turn it off
      if software checksum was computed.
    - Add code to correctly receive full sized 802.1ad frames.

Vladislav Yasevich (2):
  tg3: Work around HW/FW limitations with vlan encapsulated frames
  tg3: Allow for receive of full-size 8021AD frames

 drivers/net/ethernet/broadcom/tg3.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

-- 
1.9.3
