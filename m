From: "Stian Skjelstad" <stian@nixia.no>
Subject: Is this intended design, or a bug? Missing event for gateway being
 deleted
Date: Fri, 6 Apr 2012 22:04:36 +0200
Message-ID: <b057c62fb42411fe0142037567ffaadb.squirrel@nlc.no>
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lauken.nlc.no ([195.159.66.52]:44322 "EHLO lauken.nlc.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755301Ab2DFUM5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 16:12:57 -0400
Received: from nlc.no (lauken.nlc.no [127.0.0.1])
	by lauken.nlc.no (Postfix) with ESMTP id DD852D2F41
	for <netdev@vger.kernel.org>; Fri,  6 Apr 2012 22:04:36 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm sorry if this has been discussed before, but my google searches didn't
give me any good hints so:

I'm using rtnetlink for a project and I noticed a non-consistent behavior.
When I tear down (the last) ip address, the default gateway is removed,
but it is not announced on the netlink socket. This can also be verified
using "ip monitor". This is tested with linux kernel version 3.2.6 on ARM.





# ip monitor &
# ip addr add 10.0.0.2/8 dev eth0
2: eth0    inet 10.0.0.2/8 scope global eth0
local 10.0.0.2 dev eth0  table local  proto kernel  scope host  src 10.0.0.2
10.0.0.0/8 dev eth0  proto kernel  scope link  src 10.0.0.2
broadcast 10.0.0.0 dev eth0  table local  proto kernel  scope link  src
10.0.0.2
broadcast 10.255.255.255 dev eth0  table local  proto kernel  scope link 
src 10.0.0.2
# ip route add via 10.0.1.22
default via 10.0.1.2 dev eth0
# ip addr del 10.0.0.2/8 dev eth0
Deleted 2: eth0    inet 10.0.0.2/8 scope global eth0
Deleted 10.0.0.0/8 dev eth0  proto kernel  scope link  src 10.0.0.2
Deleted broadcast 10.255.255.255 dev eth0  table local  proto kernel 
scope link  src 10.0.0.2
Deleted broadcast 10.0.0.0 dev eth0  table local  proto kernel  scope link
 src 10.0.0.2
Deleted local 10.0.0.2 dev eth0  table local  proto kernel  scope host 
src 10.0.0.2

(No Deleted default via line here)


Stian Skjelstad
