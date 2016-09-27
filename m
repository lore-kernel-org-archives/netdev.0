From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH v5 0/7] implement rfc7559 ipv6 router solicitation backoff
Date: Tue, 27 Sep 2016 02:52:36 -0700
Message-ID: <1474969963-17402-1-git-send-email-zenczykowski@gmail.com>
References: <CANP3RGfHPZLHFnp4Rq8_dRNCro6Uh8O8767NgoGu7gvzu5h9BQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36720 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932222AbcI0Jw5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 05:52:57 -0400
Received: by mail-pa0-f46.google.com with SMTP id qn7so4062747pac.3
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 02:52:56 -0700 (PDT)
In-Reply-To: <CANP3RGfHPZLHFnp4Rq8_dRNCro6Uh8O8767NgoGu7gvzu5h9BQ@mail.gmail.com>
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

Patches 6 and 7 switch the defaults over to enable this by default
(defaults come from the RFC).

[PATCH v5 1/7] ipv6 addrconf: enable use of proc_dointvec_minmax in
[PATCH v5 2/7] ipv6 addrconf: remove addrconf_sysctl_hop_limit()
[PATCH v5 3/7] ipv6 addrconf: rtr_solicits == -1 means unlimited
[PATCH v5 4/7] ipv6 addrconf: add new sysctl
[PATCH v5 5/7] ipv6 addrconf: implement RFC7559 router solicitation
[PATCH v5 6/7] ipv6 addrconf: change default
[PATCH v5 7/7] ipv6 addrconf: change default MAX_RTR_SOLICITATIONS

Changes v4->v5:
  added 'const' qualifier to extra1/2 constants - requires (void*) casting
  switched away from shifts by 20 to do_div(..., 1000000)
  switched to variable names from the rfc, elaborated a bit in the comments

Changes v3->v4:
  added subject line to cover letter

Changes v2->v3:
  added cover letter

Changes v1->v2:
  avoid 64-bit divisions to fix 32-bit build errors
