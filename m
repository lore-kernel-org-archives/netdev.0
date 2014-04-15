From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v2 0/2] ipv4: fix flowi4_iif for input routing
Date: Tue, 15 Apr 2014 16:25:33 -0700
Message-ID: <1397604335-12752-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Biederman <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:60797 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229AbaDOX0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 19:26:02 -0400
Received: by mail-pa0-f50.google.com with SMTP id kq14so10175812pab.37
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2014 16:26:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes ->flowi4_iif for input routing and rp filter,
based on suggestion from Julian. See per patch for details.

v1 -> v2:
* merge the first two patches into one
* fix fib_check_nh() too
* add this cover letter

Cc: Eric Biederman <ebiederm@xmission.com>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>

Cong Wang (2):
  ipv4,fib: pass LOOPBACK_IFINDEX instead of 0 to flowi4_iif
  ipv4,route: pass 0 instead of LOOPBACK_IFINDEX to
    fib_validate_source()

 include/net/flow.h                | 10 +++++++++-
 include/net/net_namespace.h       |  9 +--------
 net/ipv4/fib_frontend.c           |  2 +-
 net/ipv4/fib_semantics.c          |  1 +
 net/ipv4/ipmr.c                   |  2 +-
 net/ipv4/netfilter/ipt_rpfilter.c |  5 +----
 net/ipv4/route.c                  |  3 +--
 net/ipv6/ip6mr.c                  |  2 +-
 8 files changed, 16 insertions(+), 18 deletions(-)

-- 
1.8.3.1
