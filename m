From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 0/3 net-next] xen-netback: guest Rx queue drain and stall fixes
Date: Wed, 22 Oct 2014 14:08:52 +0100
Message-ID: <1413983335-8307-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:19173 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933328AbaJVNJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 09:09:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes two critical xen-netback bugs.

1. Netback may consume all of host memory by queuing an unlimited
   number of skb on the internal guest Rx queue.  This behaviour is
   guest triggerable.

2. Carrier flapping under high traffic rates which reduces
   performance.

The first patch is a prerequite.  Removing support for frontends with
feature-rx-notify makes it easier to reason about the correctness of
netback since it no longer has to support this outdated and broken
mode.

David
