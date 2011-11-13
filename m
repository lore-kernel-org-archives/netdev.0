From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 0/8 2.6.32] CVE-2010-4251: packet backlog can get too large
Date: Sun, 13 Nov 2011 23:13:36 +0300
Message-ID: <20111113201336.GA1362@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <greg@kroah.com>, netdev@vger.kernel.org,
	Zhu Yi <yi.zhu@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:35299 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777Ab1KMUN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 15:13:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm still very new to this whole -stable business so please let me
know if I do somethig wrong.

This patch series is to address CVE-2010-4251 for the 2.6.32 stable
kernel.  Here is the CVE summary:

 "The socket implementation in net/core/sock.c in the Linux kernel
  before 2.6.34 does not properly manage a backlog of received
  packets, which allows remote attackers to cause a denial of service
  (memory consumption) by sending a large amount of network traffic,
  as demonstrated by netperf UDP tests."

[patch 1/8] introduces sk_add_backlog_limited()
[patch 2-7/8] change each network protocol to use sk_add_backlog_limited()
	where appropriate.
[patch 8/8] renames sk_add_backlog() to __sk_add_backlog() and
	sk_add_backlog_limited() to sk_add_backlog().

The patches mostly apply without changes.  The exception is:
[patch 2/8] udp: use limited socket backlog
Then the rename [patch 8/8] needed to be changed as well to match.

regards,
dan carpenter
