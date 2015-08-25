From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RFC 0/5] net: L2 only interfaces
Date: Tue, 25 Aug 2015 15:50:10 -0700
Message-ID: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, linux@roeck-us.net,
	jiri@resnulli.us, sfeldma@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33994 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755685AbbHYWxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 18:53:48 -0400
Received: by pabzx8 with SMTP id zx8so47371061pab.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 15:53:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series implements a L2 only interface concept which basically denies
any kind of IP address configuration on these interfaces, but still allows them
to be used as configuration end-points to keep using ethtool and friends.

A cleaner approach might be to finally come up with the concept of net_port
which a net_device would be a superset of, but this still raises tons of
questions as to whether we should be modifying userland tools to be able to
configure/query these interfaces. During all the switch talks/discussions last
year, it seemed to me like th L2-only interface is closest we have to a
"network port".

Comments, flames, flying tomatoes welcome!

Florian Fainelli (5):
  net: add IFF_L2_ONLY flag
  net: ipv4: Skip in_dev initialization for IFF_L2_ONLY interfaces
  net: ipv6: Skip in6_dev initialization for IFF_L2_ONLY interfaces
  net: dsa: Flag slave network devices with IFF_L2_ONLY
  net: dsa: bcm_sf2: Allow disabling tagging protocol

 drivers/net/dsa/bcm_sf2.c | 16 +++++++++++++---
 include/uapi/linux/if.h   |  5 ++++-
 net/dsa/slave.c           |  1 +
 net/ipv4/devinet.c        |  3 +++
 net/ipv6/addrconf.c       |  4 ++++
 5 files changed, 25 insertions(+), 4 deletions(-)

-- 
2.1.0
