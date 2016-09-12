From: Andreas =?iso-8859-1?Q?H=FCbner?= <andreas@k4n.de>
Subject: icmpv6: issue with routing table entries from link local addresses
Date: Mon, 12 Sep 2016 16:27:32 +0200
Message-ID: <20160912142732.GI26782@targo.k4n.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from targo.k4n.de ([213.133.103.195]:38413 "EHLO targo.k4n.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758925AbcILOhj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 10:37:39 -0400
Received: from localhost (localhost [127.0.0.1])
        by targo.k4n.de (Postfix) with ESMTP id D2F28480D4D
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 16:27:41 +0200 (CEST)
Received: from targo.k4n.de ([127.0.0.1])
        by localhost (targo.k4n.de [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id aGZPTlMopBgO for <netdev@vger.kernel.org>;
        Mon, 12 Sep 2016 16:27:39 +0200 (CEST)
Received: from targo.k4n.de (targo.k4n.de [213.133.103.195])
        by targo.k4n.de (Postfix) with ESMTPSA id C0C03480D38
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 16:27:39 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm currently debugging a potential issue with the icmpv6 stack and
hopefully this is the correct place to ask. (Was actually looking for a
more specific list, but didn't find anything. Please point me to a more
apropriate list if this is out of place here.)

I have the following setup:
  - 2 directly connected hosts (A+B), both have only link local addresses
    configured (interface on both hosts is eth0)
  - host B is also connected to another host C (via interface eth1)
  - main routing table (relevant part) on host B looks like this:

      fe80::/64 dev eth1  proto kernel  metric 256
      fe80::/64 dev eth0  proto kernel  metric 256

  - host A is trying to ICMPv6 ping the link local address of host B

The issue I currently have is, that the echo reply that host B should
generate is never sent back to host A. If I change the order of the
routing table entries on host B, everything works fine.
(host A is connected on eth0)

I'm wondering, if this is how it is supposed to work. Do we need to do a
routing table lookup when generating an ICMPv6 echo reply for link local
addresses?  (From my understanding, this is not done in the neighbour
discovery stack, so why here?)

Actually, I'm convinced I must be doing something wrong here. The setup
for the issue is quite trivial, someone would have tripped over it
already. The only condition is that one host has multiple interfaces
with ipv6 enabled.

Any help in shedding some light onto this issue would be appreciated.


Thanks,
Andreas
