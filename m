From: Jonathan Thibault <jonathan@navigue.com>
Subject: Tagged/untagged and gretap bridging question.
Date: Thu, 13 Jan 2011 17:07:36 -0500
Message-ID: <4D2F77A8.1010700@navigue.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.navigue.com ([74.117.40.3]:43120 "EHLO mail.navigue.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757044Ab1AMWOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jan 2011 17:14:36 -0500
Received: from [192.168.7.132] (unknown [74.117.40.10])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.navigue.com (Postfix) with ESMTPSA id 1E09F528F95
	for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 17:07:36 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings list,

Assuming the following network setup of three locations linked by two
ethernet over gre (gretap) tunnels.

I am assuming that a broadcast on the local network, if it comes
untagged to eth0 will reach both network1 and network2 untagged.

My main question is about a broadcast happening in the tagged portion of
(local network).  Is there a chance for an ethernet broadcast in vlan 1
on the local network to reach remote network 2?  I'm thinking not, but
if I tcpdump an interface that has vlans enabled, I will see the tagged
packets on eth0.  As such I wonder if they will travel through br0 to
the remote locations as well, something I would rather avoid.

(local network)
|                                              (remote network 1)
| eth0.1 <--br1--> gre1.1                                       |
+-eth0   <--br0--> gre1-- (l3_to_host1) -- gre0 <--br0--> eth0-+
            |
            +----> gre2 -- (l3-to_host2) -- gre0 <--br0--> eth0-+
  eth0.2 <--br2--> gre2.2                                       |
                                               (remote network 2)

Of interest too is knowing if the tags will survive all the way to
remote networks or if I need to enable vlans on the remote gretap and
ethernet interfaces as well for them to work.

Alternatively, the setup would look like this:

(local network)
|                                              (remote network 1)
| eth0.1 <--br1--> gre1.1                                       |
| eth0.3 <--br0--> gre1-- (l3_to_host1) -- gre0 <--br0--> eth0-+
+-eth0
  eth0.4 <--br3-->gre2 -- (l3-to_host2) -- gre0 <--br0--> eth0-+
  eth0.2 <--br2--> gre2.2                                       |
                                               (remote network 2)

The goal being not to see any untagged frames coming out on the local
network from remote locations and instead having them appear in specific
local vlans.

So at the core of my questions really is this:  Will bridging the
untagged portion of an interface that has vlans enabled (eth0 when
eth0.x exists) let tagged frames go through to other members of the bridge?

Thanks for your collective wisdom,

Jonathan

P.S.:  Please include me in the CC, I am not currently a member of the list.
