From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 0/2] avoid possible deadlock while enable and disable bearer
Date: Thu, 8 Aug 2013 18:45:01 +0800
Message-ID: <520376AD.7080404@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:11801 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757726Ab3HHKpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 06:45:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will occur two deadlock warming When run the command such as:

tipc-config -netid=1234 -addr=1.1.3 -be=eth:eth0
tipc-config -netid=1234 -addr=1.1.3 -bd=eth:eth0

The reason is that the tipc_link_delete() will cancel the link_timeout() and
disc_timeout() when disable the bearer, the xxx_timeout() will require b_ptr->lock,
but the b_ptr->lock is already hold, so the deadlock will occur.

We need to unlock the b_ptr->lock when calling xxx_timeout().

Ding Tianhong (1):
  tipc: avoid possible deadlock while remove link_timeout()

Wang Weidong (1):
  tipc: avoid possible deadlock while remove disc_timeout()

 net/tipc/bearer.c | 14 ++++++++++----
 net/tipc/link.c   |  2 ++
 2 files changed, 12 insertions(+), 4 deletions(-)

-- 
1.8.2.1
