From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v1 0/8] xen-netback: support toeplitz hashing
Date: Fri, 12 Feb 2016 10:13:17 +0000
Message-ID: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:24738 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbcBLKVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 05:21:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for frontend-configurable toeplitz hashing
in xen-netback (on the guest receive side). This support has been testing
against a Windows frontend and has proven to be sufficient to pass the
Microsoft HCK NDIS RSS tests.

For convenience my development branch is available at http://xenbits.xen.org/gitweb/?p=people/pauldu/linux.git;a=shortlog;h=refs/heads/rss18.

Patch #1 contains a small modification to struct sk_buff to use one more
bit's worth of space to enable full hasf information to be stored (as
opposed to simply whether a calculated hash is L4 or not).

Patch #2 re-imports the canonical netif.h from the Xen master branch at
git://xenbits.xen.org/xen.git. To minimize the diff it was post-processed
as detailed in the commit message.

Patch #3 fixes a short-coming in netback so that it can actually cope with
multiple extra_info fragments being passed from the frontend on the
guest transmit side.

Patch #4 is a trivial patch to reduce log spam from netback.

Patch #5 adds support for a new shared ring for control messages between
frontend and backend as detailed in the updated netif.h.

Patch #6 builds on patch #5 and adds support for messages passed from the
frontend to configure a toeplitz hash of packets on the guest receive side.

Patch #7 adds code to pass the hash calculated by netback to the frontend

Patch #8 adds code to take hashes calculated by the guest on its transmit
side and set the approprate values in the constructed socket buffer.
