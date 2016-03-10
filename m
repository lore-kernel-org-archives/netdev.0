From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 0/3] xen-netback: fix multiple extra info handling
Date: Thu, 10 Mar 2016 12:30:25 +0000
Message-ID: <1457613028-10381-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:32299 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbcCJMkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 07:40:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a frontend passes multiple extra info fragments to netback on the guest
transmit side, because xen-netback does not account for this properly, only
a single ack response will be sent. This will eventually cause processing
of the shared ring to wedge.

This series re-imports the canonical netif.h from Xen, where the ring
protocol documentation has been updated, fixes this issue in xen-netback
and also adds a patch to reduce log spam.
