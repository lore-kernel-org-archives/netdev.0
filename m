From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 0/2] bridge: add support for IGMPv3 and MLDv2 querier
Date: Mon, 21 Nov 2016 13:03:23 +0100
Message-ID: <1479729805-23108-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, sashok@cumulusnetworks.com,
        stephen@networkplumber.org, davem@davemloft.net,
        liuhangbin@gmail.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36267 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753457AbcKUMFE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 07:05:04 -0500
Received: by mail-wm0-f47.google.com with SMTP id g23so142931755wme.1
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 04:05:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
This patch-set adds support for IGMPv3 and MLDv2 querier in the bridge.
Two new options which can be toggled via netlink and sysfs are added that
control the version per-bridge:
 multicast_igmp_version - default 2, can be set to 3
 multicast_mld_version - default 1, can be set to 2 (this option is
                         disabled if CONFIG_IPV6=n)

Note that the names do not include "querier", I think that these options
can be re-used later as more IGMPv3 support is added to the bridge so we
can avoid adding more options to switch between v2 and v3 behaviour.

The set uses the already existing br_ip{4,6}_multicast_alloc_query
functions and adds the appropriate header based on the chosen version.

For the initial support I have removed the compatibility implementation
(RFC3376 sec 7.3.1, 7.3.2; RFC3810 sec 8.3.1, 8.3.2), because there are
some details that we need to sort out.

Thank you,
 Nik


Nikolay Aleksandrov (2):
  bridge: mcast: add IGMPv3 query support
  bridge: mcast: add MLDv2 querier support

 include/uapi/linux/if_link.h |   2 +
 net/bridge/br_multicast.c    | 166 +++++++++++++++++++++++++++++++++----------
 net/bridge/br_netlink.c      |  34 ++++++++-
 net/bridge/br_private.h      |   7 ++
 net/bridge/br_sysfs_br.c     |  40 +++++++++++
 5 files changed, 210 insertions(+), 39 deletions(-)

-- 
2.1.4
