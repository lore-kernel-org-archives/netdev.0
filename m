From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: [PATCH 0/14] skb fragment API: convert network drivers (part I)
Date: Tue, 30 Aug 2011 10:17:27 +0100
Message-ID: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:12147 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689Ab1H3JR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 05:17:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series converts the first batch of network drivers to the
SKB pages fragment API introduced in 131ea6675c76. I expect there will
be ~4 similarly sized batches to convert all the drivers over.

This is part of my series to enable visibility into SKB paged fragment's
lifecycles, [0] contains some more background and rationale but
basically the completed series will allow entities which inject pages
into the networking stack to receive a notification when the stack has
really finished with those pages (i.e. including retransmissions,
clones, pull-ups etc) and not just when the original skb is finished
with, which is beneficial to many subsystems which wish to inject pages
into the network stack without giving up full ownership of those page's
lifecycle. It implements something broadly along the lines of what was
described in [1].

Cheers,
Ian.

[0] http://marc.info/?l=linux-netdev&m=131072801125521&w=2
[1] http://marc.info/?l=linux-netdev&m=130925719513084&w=2
