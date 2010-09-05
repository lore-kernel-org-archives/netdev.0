From: Changli Gao <xiaosuo@gmail.com>
Subject: net: af_packet: skb_orphan should be avoided in TX path.
Date: Mon, 6 Sep 2010 01:18:06 +0800
Message-ID: <AANLkTi=oXDgEhEjt7V+Z4Pk8kv9X4Z8aCg2yAJDzuJ1J@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38921 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753589Ab0IERS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Sep 2010 13:18:27 -0400
Received: by wyf22 with SMTP id 22so2110482wyf.19
        for <netdev@vger.kernel.org>; Sun, 05 Sep 2010 10:18:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

af_packet uses tpacket_destruct_skb() to notify its user a frame is
sent out through NIC, and the memory for that frame is available for
the others. If the driver calls skb_orphan() before the frame is sent
out successfully, and the user may fill other data into the space for
this frame, this frame will be corrupted. It became more likely after
skb_try_orphan() was added into dev_hard_start_xmit().

Am I correct?

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
