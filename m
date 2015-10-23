From: Joe Jin <joe.jin@oracle.com>
Subject: [PATCH V2 0/2] limit xen vnic max queues number to online cpus number
Date: Fri, 23 Oct 2015 17:17:37 +0800
Message-ID: <5629FB31.5060806@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
To: wei.liu2@citrix.com, Ian Campbell <ian.campbell@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41926 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbbJWJRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 05:17:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently xen vnic allowed to create lots of queues by set module param
max_queues(both netback and netfront), when queues number larger than
cpus number, it does not help for performance but need more cpu time.

This patchset limit netback and netfront max queues number to online
cpus number.

Joe Jin (2):
  xen-netback: limit xen vif max queues number to online cpus
  xen-netfront: limit vnic max_queues number to online cpus

---
Changes in v2:
  - Replace param_get_int to param_get_uint.
  - Use '%u' for unsigned int when print.
  - Replace EINVAL to ERANGE when out of range [0-CPUs].
  - Reset the perm of max_queues on sysfs to 0644.

 drivers/net/xen-netback/netback.c |   28 ++++++++++++++++++++++------
 drivers/net/xen-netfront.c        |   28 ++++++++++++++++++++++------
 2 files changed, 44 insertions(+), 12 deletions(-)
