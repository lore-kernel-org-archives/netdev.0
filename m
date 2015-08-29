From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC PATCH net-next 0/3] L3 RX handler
Date: Fri, 28 Aug 2015 17:34:20 -0700
Message-ID: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35153 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752969AbbH2Ae3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 20:34:29 -0400
Received: by pacdd16 with SMTP id dd16so77804360pac.2
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 17:34:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the VRF driver registers an Rx handler for enslaved devices.
The handler switches the skb->dev to the VRF device and sends it back for
another pass. While this works fine a side effect is that it bypasses
netfilter with the skb set to the original device.

Looking at how to provide that feature a few options come to mind:
1. Have the rx handler in the VRF driver duplicate some of the processing
   of ip_rcv up to the NF_HOOK and then switch the skb->dev to vrf device.

2. Run NF_HOOK in ip_rcv twice -- once with orig_dev and then again for dev.

3. Introduce an L3 rx-handler that provides the option of hooking packets
   at L3 rather than the current backlog loop.

This RFC looks at option 3. I wanted to get opinions on the approach
versus other options.

David Ahern (3):
  net: Introduce L3 RX Handler
  net: Add L3 Rx handler to IPv4 processing
  net: Change VRF driver to use the new L3 RX handler

 drivers/net/vrf.c         | 32 +++++++++------------------
 include/linux/netdevice.h |  6 ++++++
 net/core/dev.c            | 55 ++++++++++++++++++++++++++++++++++++++---------
 net/ipv4/ip_input.c       | 32 +++++++++++++++++++++++++--
 4 files changed, 91 insertions(+), 34 deletions(-)

-- 
1.9.1
