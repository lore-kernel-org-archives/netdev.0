From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v2 0/3] make skb_checksum_setup generally available
Date: Thu, 9 Jan 2014 10:02:45 +0000
Message-ID: <1389261768-30606-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:17892 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321AbaAIKCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 05:02:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both xen-netfront and xen-netback need to be able to set up the partial
checksum offset of an skb and may also need to recalculate the pseudo-
header checksum in the process. This functionality is currently private
and duplicated between the two drivers.

Patch #1 of this series moves the implementation into the core network code
as there is nothing xen-specific about it and it is potentially useful to
any network driver.
Patch #2 removes the private implementation from netback.
Patch #3 removes the private implementation from netfront.

v2:
- Put skb_checksum_setup in skbuff.c rather than dev.c
- remove inline
