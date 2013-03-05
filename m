From: =?ISO-8859-1?Q?Sebastian_P=F6hn?= <sebastian.poehn@googlemail.com>
Subject: tipc: MTU discovery
Date: Tue, 5 Mar 2013 13:43:29 +0100
Message-ID: <CAGUzgdKJ4pPdhx7VkGCGS8CynXgOrxhTu8dZ+s77C+WKrCcCeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: jon.maloy@ericsson.com, allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:40761 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998Ab3CEMnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 07:43:31 -0500
Received: by mail-la0-f52.google.com with SMTP id fs12so5986636lab.25
        for <netdev@vger.kernel.org>; Tue, 05 Mar 2013 04:43:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am trying to run TIPC over a link with a MTU higher than standard
1500 (actually 2k or more).

I have a Ethernet Device configured with this MTU and an overlying
VLAN with the same MTU. Link Layer looks ok, as MTU sized ICMP traffic
is sent and received unfragmented.

TIPC does not discover the higher MTU, it always keeps at 1500.
Smaller ones (1.4k) are detected correctly.

Doing some deeper investigation into the TIPC stack leaded to this observation:
State Messages larger than 1500 which as used for the MTU negotiation
do not appear in the TIPC stack. But I am able to seen them entering
the correct device.
Because of that no reply with the correct max_packet field set can be
send and the negotiation will always end up at 1.5k.

So my questions are:
# Is TIPC meant to detect and use the MTU larger than 1.5k?
# Why are the packets not passed to the TIPC stack?
