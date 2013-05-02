From: Viswanath D <viswanathd@silvanlabs.com>
Subject: NETIF_F_SG not taking effect
Date: Thu, 2 May 2013 09:49:56 +0530
Message-ID: <CAFDuRTP+gTojtnipwnxbJyKPivryd5gCUV2ScDz5Q_gOSBkAJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f48.google.com ([209.85.212.48]:45928 "EHLO
	mail-vb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708Ab3EBET5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 00:19:57 -0400
Received: by mail-vb0-f48.google.com with SMTP id q16so141565vbe.7
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 21:19:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I need help in NETIF_F_UFO to work. After reading several materials, I
have come to understand that UFO is dependent on NETIF_F_SG, which in
turn is dependent on NETIF_F_HW_CSUM and when I turn on all these
flags in ndev->features during probe, I should be seeing fragments in
skb in xmit function. Also, if the packets are UDP/TCP, then the first
fragment would the header (34/66 bytes) and the rest would be the data
pointer as given by application (iperf in this case).

But, when I print "skb_shinfo(skb)->nr_frags" in my xmit function, I
always find it zero. Also all the packet content (header + data) is
completely contained within skb->data. I also removed UFO (keeping
just SG and HW_CSUM) and the behavior remains the same.
But interestingly the checksum is not computed by the stack. I
confirmed it by dumping the UDP/TCP headers in xmit and wireshark on
receive side also reflects this.
These observations are leading me to think NETIF_F_SG flag is being
ignored by the stack for some reason.

Are there any compilation flag which can be enabled to see what is
going wrong. Could I please get some pointers on how to go about
debugging this problem. The kernel version I am using is 2.6.37.

Regards
Viswa
