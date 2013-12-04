From: Fiedler Roman <Roman.Fiedler@ait.ac.at>
Subject: Change in IPv4 TCP reset behavior after kernel upgrade
Date: Wed, 4 Dec 2013 10:09:01 +0000
Message-ID: <2ECE9D9EEF1F524185270138AE2326593BF9B5EE@S0MSMAIL112.arc.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.ait.ac.at ([62.218.164.132]:39881 "EHLO MX2.ait.ac.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755297Ab3LDKPS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 05:15:18 -0500
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

After upgrading from linux-image-3.10.17 to linux-image-3.10.21 I noticed, that afterwards reset packets started to be transmitted with ID != 0. For testing:

tcpdump -i eth0 -nn -s0 -X -vvv 'tcp[tcpflags] & tcp-rst != 0'

I did a short search to find out when and why this was changed (PATCH), but did not get any wiser.

Was this an intended change, e.g. to increase resilience against RST-packet injection/DOS scenarios? Is it just accidentally?

The ID seems to be in sequence, so it is not uninitialized memory content.

Roman

PS: The kernel was patched with the vserver-patch, this might have an influence. I did not have time yet to build a kernel without that modification.
