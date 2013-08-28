From: Andy Lutomirski <luto@amacapital.net>
Subject: Source routing without rules?
Date: Tue, 27 Aug 2013 17:16:21 -0700
Message-ID: <CALCETrVRZF0XLtH9o37Y=ZVMyyExBs7dLYFLOgJ-=vFqy+a_ig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f49.google.com ([209.85.212.49]:56396 "EHLO
	mail-vb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754315Ab3H1AQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 20:16:41 -0400
Received: by mail-vb0-f49.google.com with SMTP id w16so3500451vbb.8
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 17:16:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm about to implement a trivial source routing policy for the third
time, and this is IMO stupid.  I want to have two routes to a network.
 Each route should specify a src, and, if the flow matches the src,
then that route should win.

The rules that don't work are:

ip route add <net> via <gw1> dev <dev1> metric 0
ip route add <net> via <gw2> dev <dev2> src <dev2addr> metric 10

Even if I bind a socket to dev2addr, the outgoing packets go out dev1
to gw1.  This is exactly what I don't want to have happen.

This would fix it:

ip route add <net> via <gw1> dev <dev1> src <dev1addr> metric 0 match_src
ip route add <net> via <gw2> dev <dev2> src <dev2addr> metric 10

The semantics of match_src would be that, if set, the route only
matches if the flow has no assigned source address or if the assigned
source address matches.

(Also, if SO_BINDTODEVICE didn't require privilege, that would already
work.  Should there be a sysctl to allow anyone to use
SO_BINDTODEVICE?)

--Andy
