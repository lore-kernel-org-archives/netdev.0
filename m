From: Colin Ian King <colin.king@canonical.com>
Subject: re: sched: check negative err value to safe one level of indent
Date: Tue, 14 Feb 2017 15:10:13 +0000
Message-ID: <295e658c-d36b-94da-2efe-fb3cf72cc176@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:52808 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753755AbdBNPL7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 10:11:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiro,

A recent static analysis run with CoverityScan identified a potential
change in functionality with your recent commit "sched: check negative
err value to safe one level of indent" that landed in linux-next.

The original path for case RTM_DELTFILTER would always goto errout, but
your commit seems to goto errout only if err is non-zero zero and the
err == 0 path falls through to the RTM_GETTFILTER case.  I'm not sure if
this is an intentional change in behaviour.  From what I can make out,
there is a missing goto errout before the fall-through to RTM_GETTFILTER.

Colin
