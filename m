From: Ani Sinha <ani@aristanetworks.com>
Subject: RX/dropped counter values for tagged packets
Date: Sun, 24 Mar 2013 21:43:16 -0700
Message-ID: <CAOxq_8OrE6=XtJ9TDbL7NH9313-WutZPZP8=cRBH7pVUdBDvCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, linuxdev@anirban.org,
	linux-netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:37869 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756892Ab3CYEnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 00:43:17 -0400
Received: by mail-ie0-f177.google.com with SMTP id tp5so2517971ieb.22
        for <netdev@vger.kernel.org>; Sun, 24 Mar 2013 21:43:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello everyone :

Please bear with me if you think I said something wrong.

I was looking at the netif_receive_skb() code and it seems to me that
for vlan tagged packets, the counters are manipulated at two different
places. One is from vlan_do_receive() where the receive counters are
incremented. The other counter (the dropped counter) is incremented at
the very end of netif_receive_skb() when there are no takers for this
packet. The dropped counts are incremented for skb->dev->rx_dropped
whereas the receive counts are incremented for the vlan device
specific private stat counter values. When the numbers are reported on
/proc/net/dev (from where ifconfig gets the numbers), these two stat
counters are combined together (see dev_get_stats() where rx_dropped
is added to the device private stat numbers). So if no one is
receiving the tagged packets, it will be reported both as received and
dropped! I wonder whether I am analyzing it wrong or whether no one
has noticed this before or whether this is intentional.

Any  clarification will be greatly appreciated. Again, I could be
wrong looking at the code, so please bear with me.

Thanks

ani
