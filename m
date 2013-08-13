From: Yannick Koehler <yannick@koehler.name>
Subject: tun always return NETDEV_TX_OK, why?
Date: Tue, 13 Aug 2013 10:39:02 -0400
Message-ID: <CAJ4BwwEbBQQ=S5pd=8rHAxnOm-P7yQPv9q2D7c1D9cVh5ArAPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:59552 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754506Ab3HMOjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 10:39:03 -0400
Received: by mail-ie0-f172.google.com with SMTP id 17so10699778iea.17
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 07:39:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

  I hit a problem recently with the tun interface, it looks like when
this interface reach its txqueuelen it will then drop the packet and
return NETDEV_TX_OK unconditionally.

 That, from my little understanding of the netdev framework, appears
to be wrong and will simply eat up any pending buffer and discard them
until the queue frees itself.  That seems to be against the flow
control design in the tx queue system of the kernel.

  So, is this a bug or a misunderstanding?  Would it be ok for tun to
return NETDEV_TX_BUSY when the txqueuelen is reach and call
netif_stop_queue() so that the layer above stop sending frame to this
interface until it can cope it's current queue content?

-- 
Yannick Koehler
