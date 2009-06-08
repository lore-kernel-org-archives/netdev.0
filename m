From: Michael Tokarev <mjt@tls.msk.ru>
Subject: [Security, resend] Instant crash with rtl8169 and large packets
Date: Mon, 08 Jun 2009 17:25:27 +0400
Message-ID: <4A2D1147.8020101@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([81.13.33.159]:47143 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754167AbZFHNZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2009 09:25:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Please excuse me for the resend, --
  picked the wrong address for netdev again]

Hello.

This is a resend (sort of) of several months old email.
Previous email about this issue has been mostly ignored.

The situation is very simple: with an RTL8169 (probably
onboard) GigE card which, by default, is configured to
have MTU (maximal transmission unit) to be 1500 bytes,
it's *trivial* to instantly crash the machine by sending
it a *single* packet of size >1500 bytes (provided the
network switch can handle jumbo frames).

I verified with on several different machines - all I were
able to find with this card - and all behaves exactly the
same.

When sending a packet of size, say, 3000 bytes (ping -s 3000)
from another machine to a machine running rtl8169 with no
MTU configured, kernel OOPSes.

I captured one such OOPS (unfortunately without the first
line few lines) here:

  http://www.corpit.ru/mjt/r8169-mtu-oops.jpg

(since the network goes boom at that time, no network console
is working).

But for anyone familiar with the driver's internals it
should be easy to figure the issue out.

This is, in my opinion, quite a serious issue.  And I've no
idea why it is being ignored for several months.

Thanks.

/mjt
