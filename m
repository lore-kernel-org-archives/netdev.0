From: Martin Willi <martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Subject: [PATCH 0/2] wireless: Allow wiphy/hwsim management from user namespaces
Date: Tue,  3 May 2016 08:53:16 +0200
Message-ID: <1462258398-6749-1-git-send-email-martin@strongswan.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch set enables user namespaces having CAP_NET_ADMIN to manage
wiphy devices and create/destroy hwsim radios.

The first patch allows a caller from a non-initial user namespace to run
privileged nl80211 phy/dev operations. The second patch enables hwsim
radio management over Netlink from such namespaces. Together, with these
patches an unprivileged test environment can create user/network
namespaces and set up abitrary simulated wireless networks.

Martin Willi (2):
  nl80211: Allow privileged operations from user namespaces
  mac80211_hwsim: Allow managing radios from non-initial namespaces

 drivers/net/wireless/mac80211_hwsim.c |  88 +++++++++++++++++++-
 net/wireless/nl80211.c                | 150 +++++++++++++++++-----------------
 2 files changed, 160 insertions(+), 78 deletions(-)

--
2.7.4
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
