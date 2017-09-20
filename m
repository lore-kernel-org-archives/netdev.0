From: Colin Ian King <colin.king@canonical.com>
Subject: re: mac80211: avoid allocating TXQs that won't be used
Date: Wed, 20 Sep 2017 17:08:03 +0100
Message-ID: <3592b0b1-0455-ca9a-9ca7-702d7cf421ff@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:35438 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbdITQIG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 12:08:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes,

Static analysis with CoverityScan on linux-next today detected a null
pointer dereference issue on commit:

>From 0fc4b3403d215ecd3c05505ec1f0028a227ed319 Mon Sep 17 00:00:00 2001
From: Johannes Berg <johannes.berg@intel.com>
Date: Thu, 22 Jun 2017 12:20:29 +0200
Subject: [PATCH] mac80211: avoid allocating TXQs that won't be used

Issue: sdata is null when the sdata is dereferenced by:

                   sdata->vif.type != NL80211_IFTYPE_AP_VLAN &&
                   sdata->vif.type != NL80211_IFTYPE_MONITOR)

note that sdata is assigned a non-null much later with the statement
sdata = netdev_priv(ndev).

Detected by CoverityScan CID#1456974 ("Explicit null dereferenced")

Colin
