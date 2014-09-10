From: Vadim Kochan <vadim4j@gmail.com>
Subject: Generic way to change net namespace for wireless device
Date: Wed, 10 Sep 2014 21:01:32 +0300
Message-ID: <CAMw6YJJuPK5Ngh8vTL9_c1XUyk6tkcVpFtWyoeODhLUpJxkqLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:44181 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbaIJSBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 14:01:33 -0400
Received: by mail-qg0-f54.google.com with SMTP id z60so4206596qgd.27
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 11:01:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I see that setting of network namespace differs for wireless and for
other devices. To change netns for wireless device it is needed to use
nl80211 API. Seems wireless device must have some special way to
change netns, but what if to:

     - add new netdev_ops->ndo_set_netns callback
     - implement it in net/mac80211/iface.c
     - delegate callback from net/mac80211 to net/wireless/core.c ->
          cfg80211_switch_netns func.
     - in net/core/rtnetlink.c ->do_setlink  func check & call
          dev->netdev_ops->ndo_set_netns or call
          dev_change_net_namespace

Then it will be possible to change netns for wireless device via
RTM_SETLINK.

Regards,
