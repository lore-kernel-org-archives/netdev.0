From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH v4 0/7] implement rfc7559 ipv6 router solicitation backoff
Date: Sun, 25 Sep 2016 04:03:03 -0700
Message-ID: <1474801390-6891-1-git-send-email-zenczykowski@gmail.com>
References: <20160925.060423.854801855957024790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35442 "EHLO
        mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936523AbcIYLDZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 07:03:25 -0400
Received: by mail-pa0-f54.google.com with SMTP id oz2so53542047pac.2
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 04:03:25 -0700 (PDT)
In-Reply-To: <20160925.060423.854801855957024790.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series implements RFC7559 style backoff of IPv6 router
solicitation requests.

Patches 1 and 2 are minor cleanup and stand on their own.

Patch 3 allows a (potentially) infinite number of RS'es to be sent
when the rtr_solicits sysctl is set to -1 (this depends on patch 1).

Patch 4 is just boilerplate to add a new sysctl for the maximum
backoff period.

Patch 5 implements the backoff algorithm (and depends on the previous
patches).

Patches 6 and 7 switch the defaults over to enable this by default.

[PATCH v4 1/7] ipv6 addrconf: enable use of proc_dointvec_minmax in
[PATCH v4 2/7] ipv6 addrconf: remove addrconf_sysctl_hop_limit()
[PATCH v4 3/7] ipv6 addrconf: rtr_solicits == -1 means unlimited
[PATCH v4 4/7] ipv6 addrconf: add new sysctl
[PATCH v4 5/7] ipv6 addrconf: implement RFC7559 router solicitation
[PATCH v4 6/7] ipv6 addrconf: change default
[PATCH v4 7/7] ipv6 addrconf: change default MAX_RTR_SOLICITATIONS


Changes v3->v4:
  added subject line to cover letter

Changes v2->v3:
  added cover letter

Changes v1->v2:
  avoid 64-bit divisions to fix 32-bit build errors
