From: William Manley <william.manley@youview.com>
Subject: IGMP Unsolicited Report Interval too long for IGMPv3?
Date: Mon, 22 Jul 2013 21:43:57 +0100
Message-ID: <51ED998D.7000300@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0252.outbound.messaging.microsoft.com ([213.199.154.252]:41874
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933328Ab3GVUoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 16:44:24 -0400
Received: from mail38-db9 (localhost [127.0.0.1])	by mail38-db9-R.bigfish.com
 (Postfix) with ESMTP id 75E5760130	for <netdev@vger.kernel.org>; Mon, 22 Jul
 2013 20:44:22 +0000 (UTC)
Received: from DB9EHSMHS011.bigfish.com (unknown [10.174.16.249])	by
 mail38-db9.bigfish.com (Postfix) with ESMTP id D91BF460046	for
 <netdev@vger.kernel.org>; Mon, 22 Jul 2013 20:44:20 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an IGMP join packet is lost you will not receive data sent to the 
multicast group so if no data arrives from that multicast group in a 
period of time after the IGMP join a second IGMP join will be sent.  The 
delay between joins is the "IGMP Unsolicited Report Interval".

In the kernel this seems to be hard coded to be chosen randomly between 
0-10s.  In our use-case (IPTV) this is too long as it can cause channel 
change to be slow in the presence of packet loss.

I would guess that this 10s has come from IGMPv2 RFC2236, which was 
reduced to 1s in IGMPv3 RFC3376.

There was a thread about this on linux-rdma in 2010 in the context of IP 
over Infiniband but it seems no patches got applied as a result of the 
discussion:

http://www.mail-archive.com/linux-rdma@vger.kernel.org/msg05740.html

Would the right patch reducing the unsolicited report interval for 
IGMPv3 be acceptable now?

Thanks

Will
