From: valentina.giusti@bmw-carit.de
Subject: [PATCH 0/2] Add UID/GID info to NFQUEUE
Date: Wed, 18 Dec 2013 19:04:02 +0100
Message-ID: <1387389844-5263-1-git-send-email-valentina.giusti@bmw-carit.de>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, tgraf@redhat.com,
	jpa@google.com, pablo@netfilter.org, davem@davemloft.net,
	daniel.wagner@bmw-carit.de,
	Valentina Giusti <valentina.giusti@bmw-carit.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.microon.de ([37.252.125.21]:42497 "EHLO gattino.microon.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753427Ab3LRSLs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 13:11:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valentina Giusti <valentina.giusti@bmw-carit.de>

Hi,

this patchset adds the possibility to get the UID/GID of the socket they belong
with the NFQUEUE target.

The feature is meant to be a helper for network statistics made on a per
application basis.
In fact, letting userspace being able to associate a packet to a UID and GID
couple helps narrowing down the traffic to the application it belongs to.

One could argue that we already have this feature by means of the owner match,
but this is not true for incoming traffic. It could actually be partially true
thanks to commits 41063e9 (ipv4: Early TCP socket demux) and 421b388 (udp: 
ipv4: Add udp early demux), which allow to obtain socket information also for 
incoming TCP and UDP connections. However, as Pablo Neira Ayuso already pointed
out (http://www.spinics.net/lists/netfilter-devel/msg27952.html), enabling the
owner match on INPUT wouldn't be semantically equivalent to when it is used on
OUTPUT, even with the aforementioned early demux commits.

At the Linux Plumbers Conference 2013, there have been quite interesting 
discussions on the topic of network statistics, and it was proposed that it 
would make more sense to use NFQUEUE for this purpose, letting therefore 
userspace use the UID/GID information for application-based statistics purposes.
This way the UID and GID information of the incoming TCP and UDP traffic is not
"wasted" and can be used for more refined statistics.

For more information on what has been said at LPC2013, have a look at:

https://www.youtube.com/watch?v=ulIqVzsC03g
(Updates on 'New Challenges for Linux Network Support',
 Daniel Wagner, BMW Car IT GmbH)
https://www.youtube.com/watch?v=Fi_iyaF7Gw0
(Android netfilter changes,
 John Stultz, Linaro.org)

And also at this article:

https://lwn.net/Articles/517358/

With this patchset I am proposing an implementation that follows up the
discussions that have been made.
Please have a look at it, any comments are welcome.

-- 
Best Regards,
Val
