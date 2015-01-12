From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/8] net: dsa: modular build fixes and improvements
Date: Mon, 12 Jan 2015 13:57:38 -0800
Message-ID: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, buytenh@wantstofly.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:61964 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbbALV5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:57:52 -0500
Received: by mail-pa0-f46.google.com with SMTP id lf10so34422143pab.5
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 13:57:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series fixes some problems seen when using DSA as a module. There was
a circular functional dependency which made it impossible to successfully load a
DSA switch driver module, and impossible re-insert it afterwards. Some other
problems appearing where the lack of resource cleanup, leading to various leaks
and -EEXIST errors upon module re-insertion.

Thanks!

Florian Fainelli (8):
  net: dsa: add missing netdevice.h include
  net: dsa: make module builds work
  net: phy: fixed: allow setting no update_link callback
  net: dsa: cleanup resources upon module removal
  net: dsa: allow switch drivers to cleanup their resources
  net: dsa: bcm_sf2: factor interrupt disabling in a function
  net: dsa: bcm_sf2: cleanup resources in remove callback
  net: dsa: free distributed switch tree pointer in dsa_remove

 drivers/net/dsa/bcm_sf2.c   | 44 ++++++++++++++++++++--------
 drivers/net/phy/fixed_phy.c |  2 +-
 include/net/dsa.h           |  1 +
 net/dsa/Makefile            |  2 ++
 net/dsa/dsa.c               | 71 ++++++++++++++-------------------------------
 net/dsa/dsa_lib.c           | 68 +++++++++++++++++++++++++++++++++++++++++++
 net/dsa/dsa_priv.h          |  6 ++++
 net/dsa/slave.c             | 14 +++++++++
 8 files changed, 146 insertions(+), 62 deletions(-)
 create mode 100644 net/dsa/dsa_lib.c

-- 
2.1.0
