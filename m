From: Erik Hugne <erik.hugne@ericsson.com>
Subject: [MacVLAN] failure to deliver reassembled IPv6 multicast traffic
Date: Fri, 15 Feb 2013 18:00:28 +0100
Message-ID: <20130215170028.GG12219@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: ataschner@suse.com
To: netdev@vger.kernel.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:52168 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967Ab3BORDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 12:03:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If macvlan's are configured on a device, IPv6 multicast
traffic received on the underlying ethernet device is not
delivered properly to higher layers. Large amounts of packets are lost, and
the problem seems to get worse the more macvlans are defined
on top of the device, up to the point where no traffic is delivered
at all...


Steps to reproduce (2 hosts required)
On host 1, set up some macvlans:
ip link add link eth0 name macvlan0 type macvlan mode bridge
ip link add link eth0 name macvlan2 type macvlan mode bridge
ip link add link eth0 name macvlan3 type macvlan mode bridge
ip link set link dev macvlan0 up
ip link set link dev macvlan2 up
ip link set link dev macvlan3 up

Start a server that binds to ff02::1 scoped to eth0
./server6 -sff02::1 -eeth0


On host 2:
./client6 -dff02::1 -eeth0


This seems to only occur for large (fragmented) IPv6 multicast traffic.
If you bind to :: instead (-s:: on the server) and send to
the linklocal address of Host1/eth0, packets are delivered just fine.

Source for client6/server6 on github:
git clone git@github.com:Hugne/udp_mc.git

//E
