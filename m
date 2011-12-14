From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: linux-3.0.x regression with ipv4 routes having mtu
Date: Wed, 14 Dec 2011 17:54:16 +0200
Message-ID: <4EE8C6A8.3060308@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:52578 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755771Ab1LNPyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 10:54:21 -0500
Received: by lagp5 with SMTP id p5so440274lag.19
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2011 07:54:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm testing linux-3.0.10 and it appears to have a mtu bug with ipv4.
There was recent funniness in ipv6 side as well [1,2], but this seems
quite different.

Basically, doing something like (ipA being the IPv4 host):
 1. do a tcp session to ipA (telnet to open ipv4 port, chat, close)
 2. "ip route get ipA" to see the route cache entry
 3. "ip route add ipA via (whatever was the router) mtu 1400"
 4. "ip route flush cache"
 5. "ip route get ipA" and you still get the old same info as in step 2:
    the mtu was not updated
    (btw. how long the tcp info from step 1 gets cached? is it tunable?)

So something is does not get updated here. This used to work though.
The current production boxes where I know this work is 2.6.38.8.

Sounds like the TCP info is used if it exists. But it never gets updated
after it's gone, and the new MTU is not being updated.

- Timo

[1] http://www.spinics.net/lists/netdev/msg174468.html
[2] http://marc.info/?l=linux-netdev&m=131529445904858
