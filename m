From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] about "net: orphan frags on receive" insanity
Date: Wed, 26 Jun 2013 01:23:59 -0700
Message-ID: <1372235039.3301.126.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:39102 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195Ab3FZIX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 04:23:58 -0400
Received: by mail-ee0-f52.google.com with SMTP id c50so7239335eek.39
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 01:23:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael

Following commit added 400 bytes into __netif_receive_skb_core()

Could we revert it, and fix the problem into the callers instead ?

Thanks



commit 1080e512d44d4f67b8beb8edf25a1bbcb1066dc7
Author: Michael S. Tsirkin <mst@redhat.com>
Date:   Fri Jul 20 09:23:17 2012 +0000

    net: orphan frags on receive
    
    zero copy packets are normally sent to the outside
    network, but bridging, tun etc might loop them
    back to host networking stack. If this happens
    destructors will never be called, so orphan
    the frags immediately on receive.
    
    Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
