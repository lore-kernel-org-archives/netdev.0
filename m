From: Rob Janssen <rob.janssen76@gmail.com>
Subject: arcnet: protocol is buggy messages in 3.0 kernel, not in 2.33 kernel
Date: Thu, 3 May 2012 14:21:11 +0200
Message-ID: <CAJDhSdc5J1xzvxYhvru6kjqAbq1NAtvWQCu-tXbi4aE_NXGXrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:58426 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243Ab2ECMVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 08:21:11 -0400
Received: by vcqp1 with SMTP id p1so1183412vcq.19
        for <netdev@vger.kernel.org>; Thu, 03 May 2012 05:21:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all

Since we've moved from the 2.33 kernel to the 3.0 kernel, we see the
following kernel messages in dmesg:

protocol 001a is buggy, dev arc0 skb=c702e2f4

The device involved is an arcnet device.
The warning is logged by dev.c, see the following code snippet:

if (skb_network_header(skb2) < skb2->data ||
			    skb2->network_header > skb2->tail) {
				if (net_ratelimit())
					printk(KERN_CRIT "protocol %04x is "
					       "buggy, dev %s skb=%04x\n",
					       ntohs(skb2->protocol),
					       dev->name, skb_network_header(skb2));
				skb_reset_network_header(skb2);
			}
I added some logging, and it appears that skb2->network_header is
placed in memory beyond skb2->tail (the second check).

Does anyone have what causes this message in the 3.0 kernel and/or how
to fix this ?

Thanks in advance,

Rob Janssen
