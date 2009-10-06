From: Mallika Gautam <mallika.gautam@gmail.com>
Subject: Support of multiple default routes in Linux ?
Date: Tue, 6 Oct 2009 16:37:43 +0100
Message-ID: <9041a1390910060837g1a536bc3x624cc6a5026af83d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f217.google.com ([209.85.219.217]:36777 "EHLO
	mail-ew0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932650AbZJFPik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 11:38:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I am working on 2.6.26 kernel. I am trying to setup Policy based
routing with multiple IP addresses in same subnet, with multiple
routing tables, each having its own default gateway. I have no route
in the 'Main' table. Problem is that I am not able to add default
route in each of the routing table.

I have 3 interfaces in the same subnet, sharing the gateway. I am
using 3 different routing tables for them. I need to add this gateway
to each of the routing tables with different interface associated with
the routing table.

Routing tables look like this -

eth0: 192.168.1.1/16
eth1: 192.168.1.2/16
eth2: 192.168.1.3/16

main table: empty

---- eth0tbl: routing table for eth0 ----
192.168.0.0/16 dev eth0

--- eth1tbl: routing table for eth1 ---
192.168.0.0/16 dev eth1

--- eth2tbl: routing table for eth2 ---
192.168.0.0/16 dev eth2

#ip rule
0: from all lookup local
2: from 192.168.1.1 iif lo lookup eth0tbl
3: from all to 192.168.1.1 iif eth0 lookup eth0tbl
4: from 192.168.1.2 iif lo lookup eth1tbl
5: from all to 192.168.1.2 iif eth1 lookup eth1tbl
6: from 192.168.1.3 iif lo lookup eth2tbl
7: from all to 192.168.1.3 iif eth2 lookup eth2tbl
32766: from all lookup main ----------> /* empty */
32767: from all lookup default ----------> /* empty */

when I give following command to add default route, it returns error -
#ip route add default via 192.168.254.254 dev eth0 table eth0tbl
RTNETLINK answers: No such process.

#ip route add default via 192.168.254.254 dev eth1 table eth1tbl
RTNETLINK answers: No such process.

#ip route add default via 192.168.254.254 dev eth2 table eth2tbl
RTNETLINK answers: No such process.

arp_announce, arp_ignore and arp_filter are all set to 1.
Is there a way this can be achieved? Is this available in any of the
later kernel versions? Any pointers would be of help.

Thanks
