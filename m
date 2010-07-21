From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 0/3 net-2.6] bnx2x: Bug fixes in statistics handling
Date: Wed, 21 Jul 2010 18:58:55 +0300
Message-ID: <1279727936.14094.41.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>, dmitry@broadcom.com
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2038 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751872Ab0GUP7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 11:59:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, pls., consider applying the following patches to the net-2.6 tree.
They include 2 bugs fixes in the statistics handling flow:

1) Protect the statistics state machine state update with a spinlock.
Otherwise there was a race condition that would cause the statistics
stay enabled despite they were disabled in the LINK_DOWN event handler.

2) Protect statistics ramrod sending code and a statistics counter
update with a spin lock. Otherwise there was a race condition that would
allow sending a statistics ramrods with the same sequence number or with
sequence numbers not in a natural order, which would cause a FW assert.

Thanks,
vlad



