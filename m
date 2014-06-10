From: Milos Vyletel <milos.vyletel@gmail.com>
Subject: [patch net-next 0/5] ipv6: change sysctl to behave more like in ipv4
Date: Tue, 10 Jun 2014 12:19:08 -0400
Message-ID: <1402417153-2551-1-git-send-email-milos.vyletel@gmail.com>
To: davem@davemloft.net, amwang@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f48.google.com ([209.85.216.48]:45409 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564AbaFJQT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 12:19:29 -0400
Received: by mail-qa0-f48.google.com with SMTP id x12so3420250qac.21
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 09:19:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series changes how we treat net.sysctl.conf.all settings in a same
way it is done in ipv4. It is followup to my original patch submission at
http://patchwork.ozlabs.org/patch/350346/ where Cong and David suggested that
it should mimic IPv4 behaviour.

Furthermore code was aligned to look more like ipv4 does to make the
maintanance easier. List of patches and diffstat is below. Hopefully they are
not too long. If that's the case I can split them some more.

ipv6: align sysctl table creation code with ipv4
ipv6: rename DEVCONF* to IPV6_DEVCONF* to align
ipv6: consider net.ipv6.conf.all sysctls when
Documentation: update ipv6 part of
ipv6: copy default config values to interfaces

 Documentation/networking/ip-sysctl.txt |  48 ++-
 drivers/net/usb/cdc_mbim.c             |   2 +-
 drivers/net/vxlan.c                    |   2 +-
 include/linux/ipv6.h                   |  44 +--
 include/net/addrconf.h                 |   4 +-
 include/net/ipv6.h                     |  98 ++++-
 include/uapi/linux/ipv6.h              |  68 ++--
 net/ipv6/addrconf.c                    | 666 ++++++++++++---------------------
 net/ipv6/anycast.c                     |   4 +-
 net/ipv6/exthdrs.c                     |   8 +-
 net/ipv6/ip6_input.c                   |   4 +-
 net/ipv6/ip6_output.c                  |   9 +-
 net/ipv6/ip6mr.c                       |   8 +-
 net/ipv6/ipv6_sockglue.c               |   2 +-
 net/ipv6/mcast.c                       |  31 +-
 net/ipv6/ndisc.c                       |  41 +-
 net/ipv6/output_core.c                 |   4 +-
 net/ipv6/route.c                       |  13 +-
 18 files changed, 472 insertions(+), 584 deletions(-)
