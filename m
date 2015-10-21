From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 0/8] xen-netback/core: packet hashing
Date: Wed, 21 Oct 2015 11:36:17 +0100
Message-ID: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:21978 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465AbbJUKhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 06:37:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds xen-netback support for hash negotiation with a frontend
driver, and an implementation of toeplitz hashing as the initial negotiable
algorithm.

Patch #1 re-imports the canonical netif header from Xen, which contains
the necessary definitions and a type required by subsequent patches.
(Note that this patch is not completely style-clean since the header
includes typedefs).

Patch #2 is some cleanup in xen-netback.

Patch #3 adds code to allow multiple extra_info segments to be passed from a
frontend to xen-netback.

Patch #4 adds code to allow xen-netback to accept new hash extra_info
segments from a frontend and set the skb hash information appropriately. 

Patch #5 makes a change to struct sk_buff: one extra bit is used to allow
full hash type information to be stored, rather than just the l4_hash
boolean value.

Patch #6 adds code to xen-netback to pass L3 or L4 skb hash values to
capable frontends.

Patch #7 adds code to xen-netback to provide a configurable (by the
frontend) mapping from hash values to queue numbers.

Patch #8 adds code to xen-netback to provide toeplitz hashing of skbs.
