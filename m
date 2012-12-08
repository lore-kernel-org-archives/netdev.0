From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: ipgre rss is broken since gro
Date: Sat, 8 Dec 2012 22:35:17 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F1BFB80B2@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: "Eric Dumazet" <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2641 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007Ab2LHWfa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2012 17:35:30 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi  Eric,

I'm trying to use GRE with RSS, but it looks broken on net-next since:

60769a5dcd8755715c7143b4571d5c44f01796f1 is the first bad commit
commit 60769a5dcd8755715c7143b4571d5c44f01796f1
Author: Eric Dumazet <edumazet@google.com>
Date:   Thu Sep 27 02:48:50 2012 +0000

    ipv4: gre: add GRO capability

    Add GRO capability to IPv4 GRE tunnels, using the gro_cells
    infrastructure.

    Tested using IPv4 and IPv6 TCP traffic inside this tunnel, and
    checking GRO is building large packets.

    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 8eb4f570181b6d72abe24f8c1123b7e49134e662 fa20194bb14d1745e9271c8a962d0f140801a226 M      include
:040000 040000 6f605ade7fed9fbe5fd57d4a0c3a8dc687e64ed6 4c06b880a6a6068aa791decb900f7b449c6ec7b5 M      net

Multiple TCP streams over the tunnel cause (almost) immediately GRE interface to drop any ingress packet.

Please note that at current net-next head behavior is different - I hit null pointer dereference, I will try to bisect this behavior too.
