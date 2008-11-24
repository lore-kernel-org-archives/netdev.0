From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 0/n]: 2 is better than 1 - tcp recombining; both with SACK and rexmits
Date: Mon, 24 Nov 2008 16:21:57 +0200
Message-ID: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52538 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054AbYKXOWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:22:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Skb recombining is finally there for SACK, after fixing some accesses
to already freed memory and accounting issues and plenty of state/data
corrupters and some corner-cases which I didn't found by hitting them,
it seems to finally make enough sense and run flawlessly. But still
please read the skb part of the shifting with more care than usual
since I'm on a territory which is pretty unknown to me though I learned
a lot while figuring things out. E.g., do I set checksum fields correctly,
are pre-condition checks missing something important, etc.

The current approach already is enough to get most of the benefits from
recombining. There's still room for some improvements but they can be
built on top of this machinery once we're sure that it indeed works.
E.g, not all sack patterns are handled as good as they could be, full
shift special case optimizations, dsack/sack for already sacked skbs
w/o fragmenting, ... Just to mention some.

NOTE: Like I said before, there is a pending problem with tcpdump
getting EFAULT for some reason if cloned skbs get handled.

Also the rexmissions combining is included (comments to your concerns
in the original thread). ...and some minor code reorganization.
NOTE: there's one obvious MIBs patch for debug only purpose for those
interested enough.


--
 i.


