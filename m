From: Berend De Schouwer <berend.de.schouwer@gmail.com>
Subject: tg3 pxe weirdness
Date: Thu, 21 Sep 2017 16:23:22 +0200
Message-ID: <1506003802.18177.62.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:48663 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751886AbdIUOX2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 10:23:28 -0400
Received: by mail-wm0-f45.google.com with SMTP id m127so2335370wmm.3
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 07:23:27 -0700 (PDT)
Received: from sieve-deschouwer-co-za ([196.37.73.42])
        by smtp.gmail.com with ESMTPSA id b80sm1158920wmb.41.2017.09.21.07.23.25
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Sep 2017 07:23:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've got a machine with a Broadcom bcm5762c, using the tg3 driver, that
fails to receive network packets under some very specific conditions.

It works perfectly using a 1Gbps switch.  If, however, it first uses
PXE and then loads the Linux tg3 driver, and the switch is 100Mbps, it
no longer receives packets larger than ICMP.

It does do ARP and ping.

If it boots using PXE on a 1Gbps switch, boots into Linux, and then
it's plugged into 100 Mbps it also stops receiving packets.

mii-diag and dmesg confirm auto-negotiated speed and flow control, and
confirm temporary disconnect as the cables are moved.

PXE boots using UNDI, which then transfers a kernel using TFTP, which
transfers correctly.  The kernel boots, loads the tg3 driver, connects
the network.  Up to this point everything works.  Ping will work too. 
Any other network traffic fails.

Booting from a harddrive works fine.  I assume the UNDI driver
somewhere breaks auto-negotiation.  I've tried using mii-tool and
ethtool, but I haven't managed to make it work yet.

Is it possible to get negotiation working after PXE boot?  Are there
any tg3 driver flags that might make a difference?


Berend
