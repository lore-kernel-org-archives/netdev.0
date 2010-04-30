From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch v9 0/3] net: reserve ports for applications using fixed port numbers
Date: Fri, 30 Apr 2010 04:25:15 -0400
Message-ID: <20100430082912.5630.82405.sendpatchset@localhost.localdomain>
Cc: Octavian Purdila <opurdila@ixiacom.com>, ebiederm@xmission.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	penguin-kernel@I-love.SAKURA.ne.jp, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	Amerigo Wang <amwang@redhat.com>, adobriyan@gmail.com,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23313 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933150Ab0D3RV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 13:21:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Changes from the previous version:
- Dropped the infiniband part, because Tetsuo modified the related code,
  I will send a separate patch for it once this is accepted.
- Fixed some '\0' issues introduced by the previous version.
- Use copy_from_user(), instead of get_user().
- Use memchr().

------------------>

This patch introduces /proc/sys/net/ipv4/ip_local_reserved_ports which
allows users to reserve ports for third-party applications.

The reserved ports will not be used by automatic port assignments
(e.g. when calling connect() or bind() with port number 0). Explicit
port allocation behavior is unchanged.

There are still some miss behaviors with regard to proc parsing in odd
invalid cases (for "40000\0-40001" all is acknowledged but only 40000
is accepted) but they are not easy to fix without changing the current
"acknowledge how much we accepted" behavior.

Because of that and because the same issues are present in the
existing proc_dointvec code as well I don't think its worth holding
the actual feature (port reservation) after such petty error recovery
issues.


