From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 0/3] netlink: extended error reporting
Date: Fri,  7 Apr 2017 20:26:17 +0200
Message-ID: <20170407182620.6438-1-johannes@sipsolutions.net>
Cc: pablo@netfilter.org
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51208 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755507AbdDGS0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 14:26:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So this is my first draft of what we'd talked about at netconf.
I'm not super happy with the way we have to pass the extended
error struct, but I don't see a way to implement reporting any
dynamic information (like error offsets) in any other way.

Alexander Shishkin had a nice way of reporting static extended
error data, but that isn't really suitable for reporting the
offset or even reporting the broken attribute from nla_parse().

Speaking of nla_parse(), that'll be somewhat complicated to do
since we'll have to track the offsets of where we're parsing,
but it might be possible since the nlattrs are just pointers
into the message, so (optionally?) passing the skb as well can
allow us to fill the offset information.

johannes
