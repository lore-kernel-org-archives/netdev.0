From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 0/2]  add 'private' and 'vepa' attributes to ipvlan modes
Date: Thu, 26 Oct 2017 15:09:06 -0700
Message-ID: <20171026220906.34686-1-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Changgong Li <chonggangli@google.com>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:49726 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbdJZWJV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 18:09:21 -0400
Received: by mail-oi0-f65.google.com with SMTP id w197so8144173oif.6
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 15:09:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

IPvlan has always been operating in bridge-mode for its supported modes i.e.
if the packets are destined to the adjacent neighbor dev, then IPvlan driver
will switch the packet internally without needing the packets to hit the
wire or get routed. However, there are situations where this bridge-mode is
not needed. e.g. two private processes running inside two namespaces which
are having one IPvlan slave each for its namespace but sharing the master. These
processes should reach the outside world through the master device but at
the same time the bridge function should not work. Currently that's not
possible hence the private attribute for the selected mode comes in play.

VEPA or 802.1Qbg on the other hand has limited appeal with IPvlan since IPvlan
uses the mac-address of the lower device. So packets that are destined to 
the adjacent neighbor slave-dev will have same src and dest mac. When these
packets reach the external switch/router, they will send you the redirect
message which the host will have to deal with. Having said that this attribute 
will have appeal in debugging as IPvlan will not switch / short-circuit 
packets internally. e.g. using VEPA mode with lower-device in loopback mode
will avoid some complicated set-ups that use non-local-bind with some route
jugglery.

This patch-set implements these attributes for the existing modes that
IPvlan has. Please see individual patches for their detailed implementation.
A subsequent ip-utils patch is needed and will be sent soon.

Mahesh Bandewar (2):
  ipvlan: introduce 'private' attribute for all existing modes.
  ipvlan: implement VEPA mode

 Documentation/networking/ipvlan.txt | 42 +++++++++++++++++++++++++++++----
 drivers/net/ipvlan/ipvlan.h         | 31 ++++++++++++++++++++++++
 drivers/net/ipvlan/ipvlan_core.c    | 24 ++++++++++++++-----
 drivers/net/ipvlan/ipvlan_main.c    | 47 +++++++++++++++++++++++++++++++++++--
 include/uapi/linux/if_link.h        |  4 ++++
 5 files changed, 136 insertions(+), 12 deletions(-)

-- 
2.15.0.rc2.357.g7e34df9404-goog
