From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv3 net 0/2] net: fixes for device unregistration
Date: Thu,  9 Jul 2015 09:59:08 +0300
Message-ID: <1436425150-5612-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"Vittorio G (VittGam)" <linuxbugs@vittgam.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55514 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751659AbbGIG7l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 02:59:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Test script from Eric W. Biederman can catch a problem
where packets from backlog are processed long after the last
synchronize_net call. This can be reproduced after few tests
if commit 381c759d9916 ("ipv4: Avoid crashing in ip_error")
is reverted for the test. Incoming packets do not hold
reference to device but even if they do, subsystems do not
expect packets to fly during and after the NETDEV_UNREGISTER
event.

The first fix has the cost of netif_running check in fast path.
The second fix calls rcu_read_lock while local IRQ is disabled,
I hope this is not against the rules.

Julian Anastasov (2):
  net: do not process device backlog during unregistration
  net: call rcu_read_lock early in process_backlog

 net/core/dev.c | 38 ++++++++++++++++++++------------------
 1 file changed, 20 insertions(+), 18 deletions(-)

-- 
1.9.3
